//
//  URLSessionDispatcher.swift
//  RemoteResource
//
//  Created by theffc on 23/01/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public class URLSessionDispatcher: NetworkDispatcher {
    
    struct Input {
        let configuration: NetworkConfiguration
        let session: URLSessionProtocol
        let urlRequestBuilder: URLRequestBuilder
    }
    
    // MARK: - Properties
    
    let input: Input
    
    var configuration: NetworkConfiguration {
        return input.configuration
    }
    
    // MARK: - Initialization
    
    init(input: Input) {
        self.input = input
    }
    
    // MARK: - Dispatch
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion) {
        guard let urlRequest = input.urlRequestBuilder.buildUrlFor(request: request) else {
            completion(NetworkResponse(
                // TODO: improve error handling
                request: request, state: .couldNotResolveResource
            ))
            return
        }
        
        let task = input.session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            let state = self.responseStateFor(data: data, response: response, error: error)
            
            let response = NetworkResponse(
                request: request, state: state
            )
            
            completion(response)
        }
        
        task.resume()
    }
    
    func responseStateFor(
        data: Data?, response: HTTPURLResponse?, error: Error?
    ) -> NetworkResponse.State
    {
        switch (data, response, error) {
            
        case (let data?, let response?, nil):
            return .respondedWithSuccess(.init(
                httpResponse: response, data: data
            ))
            
        case (let data?, let response?, let error?):
            return .respondedWithError(.init(
                response: .init(httpResponse: response, data: data),
                error: error
            ))
            
        case (nil, nil, let error?):
            return .networkError(error)
            
        default:
            assertionFailure("this case should not happen. In case it happens, you should add a new state in the NetworkResponse")
            return .networkError(NSError())
        }
    }
    
}

class URLHelper {
    
    func escapedParameters(_ parameters: [String: Any]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            for (key, value) in parameters {
                // make sure that it is a string value
                let stringValue = "\(value)"
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
}
