//
//  URLSessionProtocols.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

// MARK: - Extensions

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension URLSession: URLSessionProtocol {
    
    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
    {
        let task = dataTask(with: request) { (data, response, error) in
            let http = response as? HTTPURLResponse
            
            let haveResponseButIsNotHttp = (http == nil) && (response != nil)
            if haveResponseButIsNotHttp {
                assertionFailure("since this library is dedicated to HTTP, this should never happen")
                completionHandler(nil, nil, ErrorResponseNotHttp(otherError: error))
            } else {
                completionHandler(data, http, error)
            }
        }
        
        return task as URLSessionDataTaskProtocol
    }
    
    struct ErrorResponseNotHttp: Error {
        let otherError: Error?
    }
}
