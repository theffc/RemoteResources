//
//  NetworkConfiguration.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public struct NetworkConfiguration {
    
    /// Defines the environment name, ie. Production, Staging, Dev and so on
    let name: String
    
    /// Here we can put the default headers that we need for all requests
    let headers: [String: String]
    
    /// The base URL for the environment
    let baseURL: URL
    
    public init(name: String, headers: [String: String] = [:], baseURL: URL) {
        self.name = name
        self.headers = headers
        self.baseURL = baseURL
    }
}
