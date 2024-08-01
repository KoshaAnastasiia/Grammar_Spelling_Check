//
//  ErrorURLBuilder.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 01.08.2024.
//

import SwiftUI

struct ErrorURLBuilder {
    private static let baseURL = URL(string: "check://openError")!
    
    let errorId: String
    private static let errorIdKey = "id"
    
    private var queryItems: [URLQueryItem] {
        [
            .init(name: Self.errorIdKey, value: errorId)
        ]
    }

    var url: URL {
        var components = URLComponents(string: Self.baseURL.absoluteString)!
        components.queryItems = queryItems
        return components.url!
    }

    init(errorId: String) {
        self.errorId = errorId
    }

    init?(url: URL) {
        guard
            Self.baseURL.scheme == url.scheme,
            Self.baseURL.host == url.host,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let errorId = components.queryItems?.first(where: { $0.name == "id" })?.value
        else {
            return nil
        }
        self.errorId = errorId
    }
}
