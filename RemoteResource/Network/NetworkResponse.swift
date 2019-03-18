//
//  Network.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

struct NetworkResponse {
    
    let request: ResourceRequest
    
    let result: ResultType
    typealias ResultType = Result<Http, Error>
    
    struct Http {
        let httpResponse: HTTPURLResponse
        let data: Data
    }
    
    enum Error {
        case couldNotResolveResourceIntoUrlRequest
        case networkError(Swift.Error)
        case serverError(ServerError)
        
        /// server treated your request as an error
        struct ServerError {
            let error: Swift.Error
            let httpResponse: Http
        }
    }
}

struct NetworkResponseForResource<Resource: RemoteResource> {

    let request: Resource.Request
    
    let result: ResultType
    typealias ResultType = Result<Response, Error>
    
    struct Response {
        let typed: Resource.Response
        let http: NetworkResponse.Http
    }
    
    enum Error: Swift.Error {
        case network(NetworkResponse.Error)
        case parser(ParserError)
    }
    
    struct ParserError {
        let error: ResponseParserError
        let http: NetworkResponse.Http
    }
}
