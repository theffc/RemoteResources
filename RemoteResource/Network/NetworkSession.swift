//
//  NetworkSession.swift
//  RemoteResource
//
//  Created by Frederico Franco on 30/05/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol NetworkSessionType {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> NetworkSessionDataTask
}


public protocol NetworkSessionDataTask {
    func resume()
    func cancel()
}
