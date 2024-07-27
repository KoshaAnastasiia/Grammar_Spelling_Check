//
//  GrammarSpellingLabel.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 27.07.2024.
//

import SwiftUI

struct GrammarSpellingLabel: View {
    var image: String?
    var text: LocalizedStringKey
    var isColored: Bool
    var isOverlayed: Bool
    
    var body: some View {
        HStack {
            if let image = image {
                Image(systemName: image)
            }
            Text(text)
        }
        .font(.body)
        .foregroundStyle(isColored ? Color.purple : Color.gray)
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isOverlayed ? Color.purple.opacity(0.7) : Color.gray.opacity(0.7), lineWidth: 1)
        ).background(Color.white.cornerRadius(6))
    }
}

#Preview {
    GrammarSpellingLabel(image: "checkmark",
                         text: "hello",
                         isColored: false,
                         isOverlayed: false)
}
