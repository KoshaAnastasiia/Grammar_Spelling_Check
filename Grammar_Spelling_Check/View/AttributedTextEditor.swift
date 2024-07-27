//
//  AttributedTextEditor.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 25.09.2023.
//

import SwiftUI

struct AttributedTextEditor: UIViewRepresentable {
    @Binding var text: NSMutableAttributedString
    @Binding var position: NSRange?
    let replaceText: (_ range: NSRange, _ text: String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
        if let position {
            uiView.selectedRange = position
        }
        uiView.font = UIFont.systemFont(ofSize: 16)
        uiView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1, alpha: 1)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AttributedTextEditor

        init(_ parent: AttributedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = NSMutableAttributedString(attributedString: textView.attributedText)
            parent.position = textView.selectedRange
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            parent.replaceText(range, text)
            return true
        }
    }
}
