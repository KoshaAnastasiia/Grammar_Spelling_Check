//
//  GrammarAndSpellingCheckView.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 25.09.2023.
//

import SwiftUI

struct GrammarAndSpellingCheckView: View {
    // MARK: - Text state properties

    @State private var inputText = NSMutableAttributedString(string: "")
    @State private var errors: [GrammarAndSpellingData.Error] = []
    @State private var position: NSRange?

    @State private var selectedError: GrammarAndSpellingData.Error?

    private struct TextUpdate: CustomDebugStringConvertible {
        let range: NSRange
        let updateWith: String
        let text: String
        
        var debugDescription: String {
            "'\(text)' (\(range.location)->\(range.length)) '\(updateWith)'"
        }
    }
    @State private var pendingTextUpdates: [TextUpdate] = []

    private enum CheckState {
        case ready
        case checking
        case checked
    }
    @State private var checkState: CheckState = .ready

    // MARK: - Body

    var body: some View {
        VStack {
            ScrollView {
                AttributedTextEditor(
                    text: $inputText,
                    position: $position,
                    replaceText: { (range, text) in
                        let update: TextUpdate = .init(range: range, updateWith: text, text: inputText.string)
                        print("Pending update: \(update)")
                        pendingTextUpdates.append(update)
                    }
                )
                .padding(.all, 20)
                .frame(height: 500)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray))
                .padding(.horizontal, 24)
            }
            Spacer()
            HStack {
                Spacer()
                Button(
                    action: buttonState.action,
                    label: {
                        GrammarSpellingLabel(
                            image: buttonState.iconName,
                            text: buttonState.title,
                            isColored: true,
                            isOverlayed: true
                        )
                    }
                )
                .opacity(checkState == .checked ? 0.5 : 1)
                .padding(.horizontal, 8)
                    
            }
        }
        .background(.white)
        .onChange(of: inputText) { _, _ in
            if chooseUpdate() {
                modifyText()
            }
        }
        .onOpenURL { errorURL in
            print("will open mistake URL: \(errorURL)")
            handleSelectionError(errorURL)
        }
        .sheet(
            item: $selectedError,
            onDismiss: {
                selectedError = nil
            },
            content: { error in
                ErrorPopupView(error: error, inputText: $inputText, errorsArray: $errors)
                    .presentationDetents([.fraction(0.65), .large])
                    .presentationDragIndicator(.visible)
            }
        )
    }
    
    // MARK: - Getting updates for text from user interactions

    private func chooseUpdate() -> Bool {
        defer {
            pendingTextUpdates = []
        }
        guard let valid = pendingTextUpdates.first (where: {
            $0.text.count - $0.range.length + $0.updateWith.count == inputText.string.count
        }) else {
            print("no valid update")
            return false
        }
        print("take update: \(valid)")
        makeUpdate(pendingTextUpdate: valid)
        return true
    }
    
    private func makeUpdate(pendingTextUpdate: TextUpdate) {
        errors = errors.compactMap {
            let isUpdateFullyRightFromError = $0.offset + $0.length < pendingTextUpdate.range.location
            if isUpdateFullyRightFromError {
                return $0
            }
            let isUpdateFullyLeftFromError = pendingTextUpdate.range.location + pendingTextUpdate.range.length < $0.offset
            if isUpdateFullyLeftFromError {
                let deltaLength = pendingTextUpdate.updateWith.count - pendingTextUpdate.range.length
                return $0.offset(by: deltaLength)
            }
            let isUpdateFullyInsideError = pendingTextUpdate.range.lowerBound > $0.offset && pendingTextUpdate.range.upperBound < $0.offset + $0.length
            if isUpdateFullyInsideError {
                let deltaLength = pendingTextUpdate.updateWith.count - pendingTextUpdate.range.length
                return $0.length(by: deltaLength)
            }
            var errorRange = NSRange(location: $0.offset, length: $0.length)
            guard let intersection = pendingTextUpdate.range.intersection(errorRange) else {
                return $0
            }
            // Clipping lenth of interval by substracting intersection
            errorRange.length = errorRange.length - intersection.length
            let isErrorStartInsideUpdateInterval = intersection.lowerBound == errorRange.lowerBound
            if isErrorStartInsideUpdateInterval {
                // Clipping the start of error range by setting start of error range equal to intersection end
                errorRange.location = intersection.upperBound
            }
            return $0.applying(range: errorRange)
        }
        print("updated errors: \(errors)")
    }

    // MARK: - Show popup with selected mistake

    private func handleSelectionError(_ url: URL) {
        guard let urlBuilder = ErrorURLBuilder(url: url) else {
            return
        }
        
        selectedError = errors.first(where: {
            $0.id == urlBuilder.errorId
        })
    }
        
    private func modifyText() {
        inputText = inputText.string.hilightedText(errors: errors)
    }
    
    private func getGrammarCheckRequest(requestText: String) async -> GrammarAndSpellingData? {
        do {
            return try await APIService().checkGrammarAndSpelling(text: requestText)
        } catch {
            debugPrint(String(describing: error))
            return nil
        }
    }
}

#Preview {
    GrammarAndSpellingCheckView()
}

extension String {
    func hilightedText(errors: [GrammarAndSpellingData.Error]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor:  UIColor.black
            ]
        )
        errors
            .forEach { error in
                let color: UIColor
                if error.type == "grammar" {
                    color = UIColor(red: 1, green: 0.38, blue: 0.53, alpha: 0.1)
                } else if error.type == "spelling" {
                    color = UIColor(red: 0.24, green: 0.29, blue: 0.85, alpha: 0.1)
                } else {
                    return
                }
                let range = NSRange(location: error.offset, length: error.length)
                attributedString.addAttribute(.backgroundColor, value: color, range: range)
                attributedString.addAttribute(
                    .link,
                    value: ErrorURLBuilder(errorId: error.id).url,
                    range: range
                )
            }
        return attributedString as NSMutableAttributedString
    }
}

// MARK: - Action Button

private extension GrammarAndSpellingCheckView {
    struct ButtonState {
        let title: LocalizedStringKey
        let iconName: String
        let action: () -> Void
    }

    var buttonState: ButtonState {
        switch checkState {
        case .ready:
            return .init(
                title: "Check",
                iconName: "lasso.and.sparkles",
                action: checkTextAction
            )
        case .checking:
            return .init(
                title: "Checking",
                iconName: "slowmo",
                action: {}
            )
        case .checked:
            return .init(
                title: "Reset",
                iconName: "checkmark",
                action: resetTextAction
            )
        }
    }

    private func checkTextAction() {
        Task {
            checkState = .checking
            let grammarSpelling = await getGrammarCheckRequest(requestText: inputText.string)
            errors = grammarSpelling?.response.errors ?? []
            modifyText()
            checkState = .checked
        }
    }
    
    private func resetTextAction() {
        checkState = .ready
        errors = []
        inputText = NSMutableAttributedString(string: "")
    }
}
