//
//  Request.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol ResourceRequest {

    /// Defines the endpoint we want to hit
    var path: String { get }
    
    var httpMethod: HTTPMethod { get }
    var parameters: RequestParameters { get }
    var headers: [String: String]? { get }
}

public enum HTTPMethod: String {
    case get
    case put
    case post
    case patch
    case delete
    
    var name: String {
        return self.rawValue.uppercased()
    }
}

public enum RequestParameters {
    case empty
    case body(_: [String: Any])
    case url(_: [String: Any])
}
