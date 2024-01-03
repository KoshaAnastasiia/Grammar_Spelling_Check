//
//  UnselectedLabel.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 27.09.2023.
//

import SwiftUI

struct UnselectedLabel: View {
    var isGrammar: Bool
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.all, 7)
            .background(isGrammar ? Color(red: 1, green: 0.38, blue: 0.53, opacity: 0.1) : Color(red: 0.24, green: 0.29, blue: 0.85, opacity: 0.1))
            .cornerRadius(10)
    }
}

#Preview {
    UnselectedLabel(isGrammar: true, text: "hello")
}
