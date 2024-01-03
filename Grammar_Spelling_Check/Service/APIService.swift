//
//  APIService.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 22.09.2023.
//

import Foundation

class APIService {
    
    func checkGrammarAndSpelling(text: String) async throws -> GrammarAndSpellingData {
        let headers = [
            "content-type": "application/json",
            "Authorization": "Basic c6KXzmdHEOgcqKC8",
            "X-RapidAPI-Key": "c6KXzmdHEOgcqKC8",
            "X-RapidAPI-Host": "api.textgears.com"
        ]

        let postJSONData = try! JSONSerialization.data(withJSONObject: ["text": text])

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.textgears.com/grammar")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)

        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postJSONData

        let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
        let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let fetchedData = try JSONDecoder().decode(GrammarAndSpellingData.self, from: try mapResponse(response: (data,response)))

        return fetchedData
    }
}
