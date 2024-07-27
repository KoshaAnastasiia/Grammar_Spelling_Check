//
//  GrammarCheckData.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 22.09.2023.
//

import Foundation

//typealias GrammarAndSpellingData = GrammarAndSpellingElement

struct GrammarAndSpellingData: Codable, Hashable {
    
    struct Description: Codable, Hashable {
        let en: String
    }
    
    struct Error: Codable, Hashable, Identifiable {
        let bad: String
        let better: [String]
        let description: Description?
        let id: String
        var length: Int
        var offset: Int
        let type: String
    }
    
    struct Response: Codable, Hashable {
        let errors: [Error]?
        let result: Bool?
    }
    
    let response: Response
    let status: Bool
}

extension GrammarAndSpellingData.Error {
    func offset(by delta: Int) -> GrammarAndSpellingData.Error {
        var error = self
        error.offset = offset + delta
        return error
    }
    
    func applying(range: NSRange) -> GrammarAndSpellingData.Error? {
        guard range.length > 0 else {
            return nil
        }
        var error = self
        error.offset = range.location
        error.length = range.length
        return error
    }
}

extension GrammarAndSpellingData.Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(\(String(bad.filter({!$0.isWhitespace}))):\(offset)->\(length))"
    }
}
