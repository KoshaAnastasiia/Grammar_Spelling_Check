//
//  AttributedTextEditor.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 25.09.2023.
//

import SwiftUI

struct AttributedTextEditor: UIViewRepresentable {
    @Binding var text: NSAttributedString
    @Binding var height: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
        uiView.font = UIFont.systemFont(ofSize: 16)
        uiView.textColor = .black
        uiView.backgroundColor = .white
        DispatchQueue.main.async {
            height = uiView.sizeThatFits(uiView.visibleSize).height
        }
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
            parent.text = textView.attributedText
        }
    }
}
