//
//  Parser.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol ResponseParser {

    func parseResponse<Resource: RemoteResource>(
        _ response: NetworkResponse.Http,
        for resource: Resource
    ) -> Result<Resource.Response, ResponseParserError>
}

enum ResponseParserError: Error {
    case notValidStatusCode(Int)
    case couldNotParse(Error)
}

struct ResponseParserDefault: ResponseParser {

    func parseResponse<Resource: RemoteResource>(
        _ response: NetworkResponse.Http,
        for resource: Resource
    ) -> Result<Resource.Response, ResponseParserError>
    {
        let statusCode = response.httpResponse.statusCode
        guard resource.validation.isValidStatusCode(statusCode) else {
            return .failure(.notValidStatusCode(statusCode))
        }
        
        do {
            let parsed = try JSONDecoder().decode(Resource.Response.self, from: response.data)
            return .success(parsed)
        } catch {
            return .failure(.couldNotParse(error))
        }
    }
}
