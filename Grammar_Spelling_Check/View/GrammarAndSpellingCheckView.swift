//
//  GrammarAndSpellingCheckView.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 25.09.2023.
//

import SwiftUI

struct GrammarAndSpellingCheckView: View {
    @State private var inputText = NSMutableAttributedString(string: "")
    @State var position: NSRange?

    @State private var grammarSpelling: GrammarAndSpellingData?
    @State private var selectedError: GrammarAndSpellingData.Error?
    
    @State private var errorsArray: [GrammarAndSpellingData.Error] = []
    @State private var isChecked: IsTextCheck = IsTextCheck.check
    @State private var preferredWords: [String] = []
    @State private var loading = false

    private struct TextUpdate {
        let range: NSRange
        let updateWith: String
        let text: String
    }

    @State private var pendingTextUpdates: [TextUpdate] = []

    private enum IsTextCheck {
        case check
        case checking
        case checked
    }
    
    var body: some View {
        VStack {
            ScrollView {
                AttributedTextEditor(text: $inputText,
                                     position: $position,
                                     replaceText: { (range, text) in
                    pendingTextUpdates.append(.init(range: range, updateWith: text, text: inputText.string))
                })
                    .padding(.all, 20)
                    .frame(height: 500)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray))
                    .padding(.horizontal, 24)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: buttonAction,
                       label: {
                    GrammarSpellingLabel(image: buttonImage(),
                                         text: buttonName(),
                                         isColored: true,
                                         isOverlayed: true)
                }).opacity(isChecked == .checked ? 0.5 : 1)
                    .padding(.horizontal, 8)
                    
            }
        }
        .background(.white)
        .onChange(of: grammarSpelling) { _, _ in
            modifyText()
        }
        .onChange(of: inputText) { _, _ in
            if !chooseUpdate() {
                inputText = inputText.string.hilightedText(errors: errorsArray)
            }
        }
        .onOpenURL { errorURL in
            print("error url: \(errorURL)")
            handleError(errorURL)
        }
        .sheet(item: $selectedError, onDismiss: {selectedError = nil}) { content in
            ErrorPopupView(error: content, inputText: $inputText, errorsArray: $errorsArray)
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func chooseUpdate() -> Bool {
        defer {
            pendingTextUpdates = []
        }
        guard let valid = pendingTextUpdates.first (where: {
            $0.text.count - $0.range.length + $0.updateWith.count == inputText.string.count
        }) else {
            return false
        }
        makeUpdate(pendingTextUpdate: valid)
        return true
    }
    
    private func makeUpdate(pendingTextUpdate: TextUpdate) {
        let delta = pendingTextUpdate.updateWith.count - pendingTextUpdate.range.length
        errorsArray = errorsArray.compactMap {
            if $0.offset + $0.length < pendingTextUpdate.range.location {
                return $0
            }
            if pendingTextUpdate.range.location + pendingTextUpdate.range.length < $0.offset {
                return $0.offset(by: delta)
            }
            var errorRange = NSRange(location: $0.offset, length: $0.length)
            guard let intersection = pendingTextUpdate.range.intersection(errorRange) else {
                return $0
            }
            if intersection.upperBound == errorRange.upperBound {
                errorRange.length = intersection.lowerBound - errorRange.lowerBound
            }
            if intersection.lowerBound == errorRange.lowerBound {
                errorRange.location = pendingTextUpdate.range.lowerBound
                errorRange.length = errorRange.length - intersection.length
                
            }
            return $0.applying(range: errorRange)
        }
    }
    
    
    private func buttonImage() -> String {
        switch isChecked {
        case .check: return "lasso.and.sparkles"
        case .checking: return "slowmo"
        case .checked: return "checkmark"
        }
    }
    
    private func buttonName() -> LocalizedStringKey {
        switch isChecked {
        case .check: return "Check"
        case .checking: return "Checking"
        case .checked: return "Reset"
        }
    }
    
    private func buttonAction() {
        switch isChecked {
        case .check: checkTextAction()
        case .checking: return
        case .checked: resetTextAction()
        }
    }
    
    private func handleError(_ url: URL) {
        guard url.scheme == "check" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        guard let action = components.host, action == "openError" else {
            return
        }
        
        guard let error = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            return
        }
        selectedError = errorsArray.first(where: {
            $0.id == error
        })
    }
    
    private func checkTextAction() {
        Task {
            isChecked = IsTextCheck.checking
            grammarSpelling = await getGrammarCheckRequest(requestText: inputText.string)
            errorsArray = grammarSpelling?.response.errors ?? []
            isChecked = IsTextCheck.checked
        }
    }
    
    private func resetTextAction() {
        isChecked = IsTextCheck.check
        errorsArray = []
        grammarSpelling = nil
        inputText = NSMutableAttributedString(string: "")
    }
    
    private func modifyText() {
        inputText = inputText.string.hilightedText(errors: errorsArray)
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
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                      .foregroundColor:  UIColor.black])
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
                let link = error.id
                let range = NSRange(location: error.offset, length: error.length)
                attributedString.addAttribute(.backgroundColor, value: color, range: range)
                attributedString.addAttribute(.link, value: String(format: "check://openError?id=%@", link), range: range)
            }
        return attributedString as NSMutableAttributedString
    }
}
