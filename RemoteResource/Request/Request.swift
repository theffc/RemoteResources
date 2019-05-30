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
    
    /// Relative to the method we want to call, that was defined with an enum above
    var method: HTTPMethod { get }
    
    /// Those are the parameters we want to pass with the request
    /// they can be used for the body or the URL
    var parameters: RequestParameters { get }
    
    /// Defines the list of headers we want to be passed along with each request
    var headers: [String: String]? { get }
}

/// This defines the type of HTTP method used to perform the request
///
/// - get: GET method
/// - put: PUT method
/// - post: POST method
/// - patch: PATCH method
/// - delete: DELETE method
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

/// Those are the parameters we want to pass with the request
/// they can be used for the body or the URL
///
/// - empty: no parameters
/// - body: send with the request bory
/// - url: send as url parameters, alongside the path
public enum RequestParameters {
    case empty
    case body(_: [String: Any])
    case url(_: [String: Any])
}
