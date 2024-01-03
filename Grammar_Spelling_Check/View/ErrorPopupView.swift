//
//  ErrorPopupView.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 26.09.2023.
//

import SwiftUI

struct ErrorPopupView: View {
    @Environment(\.dismiss) var dismiss
    var error: GrammarAndSpellingData.Error
    @Binding var inputText: NSAttributedString
    @Binding @MainActor var errorsArray: [GrammarAndSpellingData.Error]

    @State private var selectedError: String?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(error.type == "grammar" ? "You made a grammatical mistake": "You made a spelling mistake")
                .font(.system(size: 18))
                .underline()
                .foregroundStyle(error.type == "grammar" ? Color(red: 1, green: 0.38, blue: 0.53) : Color(red: 0.24, green: 0.29, blue: 0.85))
                .multilineTextAlignment(.leading)
            let description = makeErrorDescription(text: inputText.string, error: error)
            Text(AttributedString(description))
                .font(.system(size: 18))
                .multilineTextAlignment(.leading)
            HStack(spacing: 20) {
                Text("Better to use: ")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .underline()
                VStack {
                    ForEach(error.better, id: \.self) { word in
                        Button(action: { select(word) },
                               label: {
                            if selectedError == word {
                                UnselectedLabel(isGrammar: error.type == "grammar", text: word)
                            } else {
                                SelectedLabel(isGrammar: error.type == "grammar", text: word)
                            }
                        })
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: { acceptAction() },
                       label: {
                    Text("Accept")
                        .font(.system(size: 12))
                        .foregroundStyle(error.type == "grammar" ? Color(red: 1, green: 0.38, blue: 0.53) : Color(red: 0.24, green: 0.29, blue: 0.85))
                })
                .frame(width: 120, height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(error.type == "grammar" ? Color(red: 1, green: 0.38, blue: 0.53) : Color(red: 0.24, green: 0.29, blue: 0.85), lineWidth: 1)
                )
                .opacity(selectedError == nil ? 0.2: 1)
                Spacer()
                Button(action: { dismiss() },
                       label: {
                    Text("Dismiss")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                })
                .frame(width: 120, height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
            }
        }
        .padding(.all, 40)
    }
    
    @MainActor private func acceptAction() {
        if let selectedError = selectedError {
            let newInput = inputText.stringWithString(rangeToReplace: NSRange(location: error.offset, length: error.length), replacedWithString: selectedError)
            let delta = selectedError.count - error.length
            inputText = newInput
            errorsArray = errorsArray.compactMap {
                if $0.id == error.id {
                    return nil
                }
                if $0.offset < error.offset {
                    return $0
                }
                return GrammarAndSpellingElement.Error(
                    bad: $0.bad,
                    better: $0.better,
                    description: $0.description,
                    id: $0.id,
                    length: $0.length,
                    offset: $0.offset + delta,
                    type: $0.type
                )
            }
            dismiss()
        }
    }
    
    private func select(_ error: String) {
        selectedError = error
    }

    private func makeErrorDescription(text: String, error: GrammarAndSpellingData.Error) -> NSAttributedString {
        var descriptionString = ""
        let errorLower = text.index(text.startIndex, offsetBy: error.offset, limitedBy: text.endIndex) ?? text.startIndex
        let errorUpper = text.index(text.startIndex, offsetBy: error.offset + error.length, limitedBy: text.endIndex) ?? text.endIndex
        let range = errorLower..<errorUpper
        let newLower = text.index(range.lowerBound, offsetBy: -10, limitedBy: text.startIndex) ?? text.startIndex
        let newUpper = text.index(range.upperBound, offsetBy: 10, limitedBy: text.endIndex) ?? text.endIndex
        let newRange = newLower..<newUpper
        descriptionString = "..." + String(text[newRange]) + "..."
        let attributedString = NSMutableAttributedString(string: descriptionString, attributes: [.font: UIFont.systemFont(ofSize: 16),.foregroundColor:  UIColor.black])
        if let range = descriptionString.lowercased().range(of: error.bad.lowercased()) {
            attributedString.addAttribute(.backgroundColor, value: error.type == "grammar" ? UIColor(red: 1, green: 0.38, blue: 0.53, alpha: 0.1) : UIColor(red: 0.24, green: 0.29, blue: 0.85, alpha: 0.1), range: NSRange(range, in: descriptionString))
        }
        return attributedString
    }
}
