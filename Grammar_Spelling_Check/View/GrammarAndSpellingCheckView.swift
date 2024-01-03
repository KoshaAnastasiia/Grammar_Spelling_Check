//
//  GrammarAndSpellingCheckView.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 25.09.2023.
//

import SwiftUI

struct GrammarAndSpellingCheckView: View {
    @State private var inputText: NSAttributedString = NSAttributedString("")
    @State private var textHeight: CGFloat = .zero
    @StateObject var dataViewModel = GrammarAndSpellingViewModel.shared
    
    @State private var isTextCheck: Bool = false
    @State private var selectedError: GrammarAndSpellingElement.Error?
    
    @State @MainActor
    private var errorsArray: [GrammarAndSpellingData.Error] = []
    
    var body: some View {
        VStack {
            ScrollView {
                AttributedTextEditor(text: $inputText, height: $textHeight)
                    .padding(.all, 20)
                    .frame(height: 500)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray))
                    .padding(.horizontal, 24)
            }
            Spacer()
            if isTextCheck {
                Button(action: resetTextAction,
                       label: {
                    Text("Reset")
                })
            } else {
                Button(action: checkTextAction,
                       label: {
                    Text("Check")
                })
                .padding(.horizontal, 8)
                .frame(height: 44)
                .foregroundColor(.black)
                .background(.gray)
                .cornerRadius(8)
            }
            
        }
        .background(.white)
        .onChange(of: dataViewModel.data, { oldValue, newValue in
            modifyText()
        })
        .onChange(of: inputText, { oldValue, newValue in
            modifyText()
        })
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
    
    private func handleError(_ url: URL) {
        guard url.scheme == "checkapp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "openError" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        
        guard let error = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Grammar error not found")
            return
        }
        selectedError = errorsArray.first(where: {
            $0.id == error
        })
        
    }
    
    private func checkTextAction() {
        Task {
            await dataViewModel.getGrammarCheckRequest(requestText: inputText.string)
            errorsArray = dataViewModel.data?.response.errors ?? []
        }
        isTextCheck = true
    }
    
    private func resetTextAction() {
        errorsArray = []
        inputText = NSAttributedString("")
        dataViewModel.data = nil
        isTextCheck = false
    }
    
    private func modifyText() {
        inputText = Self.hilightedText(text: inputText.string, errors: errorsArray)
    }
        
    private static func hilightedText(text: String, errors: [GrammarAndSpellingData.Error]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 16),.foregroundColor:  UIColor.black])
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
                attributedString.addAttribute(.link, value: String(format: "checkapp://openError?id=%@", link), range: range)
            }
        return attributedString as NSAttributedString
    }
}

#Preview {
    GrammarAndSpellingCheckView()
}
