//
//  Network.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

struct NetworkError: Error {
    
}

struct NetworkResponse {
    
    let request: ResourceRequest
    
    let state: State
    
    enum State {
        case couldNotResolveResource
        case networkError(Error)
        case respondedWithSuccess(HttpResponse)
        case respondedWithError(ResponseWithError)
    }
    
    struct HttpResponse {
        let httpResponse: HTTPURLResponse
        let data: Data
    }
    
    struct ResponseWithError {
        let response: HttpResponse
        let error: Error
    }
}


protocol NetworkDispatcher {
    
    typealias Completion = (NetworkResponse) -> Void
    
    var configuration: Configuration { get }
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion)
}
