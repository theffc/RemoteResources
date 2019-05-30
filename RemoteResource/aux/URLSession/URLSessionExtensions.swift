//
//  URLSessionExtensions.swift
//  RemoteResource
//
//  Created by Frederico Franco on 30/05/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

extension URLSession: NetworkSessionType {
    
    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> NetworkSessionDataTask
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
        
        return task as NetworkSessionDataTask
    }
    
    struct ErrorResponseNotHttp: Error {
        let otherError: Error?
    }

}

extension URLSessionDataTask: NetworkSessionDataTask {}
