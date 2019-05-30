//
//  NetworkDispatcher.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol NetworkDispatcherType {
    
    typealias Completion = (NetworkResponse) -> Void
    
    var configuration: NetworkDispatcherConfiguration { get }
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion)
}

public struct NetworkDispatcherConfiguration {

    let builder: NetworkRequestBuilderType
    let session: NetworkSessionType
}

public struct NetworkDispatcher: NetworkDispatcherType {
    
    public let configuration: NetworkDispatcherConfiguration
}

// MARK: - Extension

public extension NetworkDispatcherType {

    func dispatch(
        request: ResourceRequest,
        completion: @escaping Completion
    ) {
        guard let urlRequest = configuration.builder.buildUrlFor(request: request) else {
            completion(NetworkResponse(
                request: request, result: .failure(.couldNotResolveResourceIntoUrlRequest)
            ))
            return
        }
        
        let task = configuration.session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            let state = self.responseResultFor(data: data, response: response, error: error)
            
            let response = NetworkResponse(
                request: request, result: state
            )
            
            completion(response)
        }
        
        task.resume()
    }
    
    func responseResultFor(
        data: Data?, response: HTTPURLResponse?, error: Error?
    ) -> NetworkResponse.ResultType
    {
        switch (data, response, error) {
            
        case (let data?, let response?, let error):
            let httpResponse = NetworkResponse.Http(httpResponse: response, data: data)
            
            if let error = error {
                return .failure(.serverError(.init(
                    error: error, httpResponse: httpResponse
                )))
            } else {
                return .success(httpResponse)
            }
            
        case (nil, nil, let error?):
            return .failure(.networkError(error))
            
        default:
            assertionFailure("this case should never happen. In case it happens, you should add a new state in the NetworkResponse")
            return .failure(.networkError(NSError()))
        }
    }
}
