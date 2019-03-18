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
                request: request, result: .failure(.couldNotResolveResourceIntoUrlRequest)
            ))
            return
        }
        
        let task = input.session.dataTask(with: urlRequest) {
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

class URLHelper {
    
    func escapedParameters(_ parameters: [String: Any]) -> String {
        guard !parameters.isEmpty else { return "" }
        
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
