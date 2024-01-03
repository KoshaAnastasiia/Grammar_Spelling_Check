//
//  GrammarAndSpellingViewModel.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 22.09.2023.
//

import Foundation

@MainActor
class GrammarAndSpellingViewModel: ObservableObject {
    static let shared = GrammarAndSpellingViewModel()
    @Published var data: GrammarAndSpellingData?

    func getGrammarCheckRequest(requestText: String) async {
        do {
            try await
            data = APIService().checkGrammarAndSpelling(text: requestText)
        } catch {
            print(error)
        }
    }
}
