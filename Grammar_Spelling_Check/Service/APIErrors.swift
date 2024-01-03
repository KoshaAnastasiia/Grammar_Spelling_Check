//
//  APIErrors.swift
//  Grammar_Spelling_Check
//
//  Created by kosha on 22.09.2023.
//

import Foundation

public enum APIError: Error, LocalizedError {
    
    case missingRequiredFields(String)
    
    case invalidParameters(operation: String, parameters: [Any])
    
    case badRequest
    
    case unauthorized
    
    case paymentRequired
    
    case forbidden
    
    case notFound
    
    case requestEntityTooLarge

    case unprocessableEntity
    
    case http(httpResponse: HTTPURLResponse, data: Data)
    
    case invalidResponse(Data)
    
    case deleteOperationFailed(String)
    
    case network(URLError)
    
    case unknown(Error?)

}

func mapResponse(response: (data: Data, response: URLResponse)) throws -> Data {
    guard let httpResponse = response.response as? HTTPURLResponse else {
        return response.data
    }
    
    switch httpResponse.statusCode {
    case 200..<300:
        return response.data
    case 400:
        throw APIError.badRequest
    case 401:
        throw APIError.unauthorized
    case 402:
        throw APIError.paymentRequired
    case 403:
        throw APIError.forbidden
    case 404:
        throw APIError.notFound
    case 413:
        throw APIError.requestEntityTooLarge
    case 422:
        throw APIError.unprocessableEntity
    default:
        throw APIError.http(httpResponse: httpResponse, data: response.data)
    }
}
