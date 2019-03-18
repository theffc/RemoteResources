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
    
    typealias ResponseValue = Result<HttpResponse, NetworkResponseError>
    let response: ResponseValue
}

struct HttpResponse {
    let httpResponse: HTTPURLResponse
    let data: Data
}

enum NetworkResponseError: Error {
    case couldNotResolveResource
    case networkError(Error)
    case serverError(ServerError)
    
    struct ServerError: Error {
        let error: Error
        let httpResponse: HttpResponse
    }
}

struct NetworkResponseForResource<Resource: RemoteResource> {

    let request: Resource.Request
    
    let response: Result<Response, Error>
    
    struct Response {
        let typed: Resource.Response
        let http: HttpResponse
    }
    
    enum Error {
        case network(NetworkResponseError)
        case parser(ResponseParserError)
    }
}
