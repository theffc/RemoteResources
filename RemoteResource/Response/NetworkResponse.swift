//
//  Network.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public struct NetworkResponse {
    
    let request: ResourceRequest
    
    let result: ResultType
    public typealias ResultType = Result<Http, Error>
    
    public struct Http {
        let httpResponse: HTTPURLResponse
        let data: Data
    }
    
    public enum Error {
        case couldNotResolveResourceIntoUrlRequest
        case networkError(Swift.Error)
        case serverError(ServerError)
        
        /// server treated your request as an error
        public struct ServerError {
            let error: Swift.Error
            let httpResponse: Http
        }
    }
}

public struct NetworkResponseForResource<Resource: RemoteResource> {

    public let request: Resource.Request
    
    public let result: ResultType
    public typealias ResultType = Result<Response, Error>
    
    public struct Response {
        let typed: Resource.Response
        let http: NetworkResponse.Http
    }
    
    public enum Error: Swift.Error {
        case network(NetworkResponse.Error)
        case parser(ParserError)
    }
    
    public struct ParserError {
        let error: ResponseParserError
        let http: NetworkResponse.Http
    }
}
