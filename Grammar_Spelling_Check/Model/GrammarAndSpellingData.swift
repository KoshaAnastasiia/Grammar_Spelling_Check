//
//  GrammarCheckData.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 22.09.2023.
//

import Foundation

typealias GrammarAndSpellingData = GrammarAndSpellingElement

struct GrammarAndSpellingElement: Codable, Hashable {
    
    struct Description: Codable, Hashable {
        let en: String
    }
    
    struct Error: Codable, Hashable, Identifiable {
        let bad: String
        let better: [String]
        let description: Description
        let id: String
        let length: Int
        let offset: Int
        let type: String
    }
    
    struct Response: Codable, Hashable {
        let errors: [Error]
        let result: Bool
    }
    
    let response: Response
    let status: Bool
}
