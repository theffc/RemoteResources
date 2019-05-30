//
//  NetworkConfiguration.swift
//  RemoteResource
//
//  Created by Frederico Franco on 30/05/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

struct NetworkFactory {
    
    let configuration: NetworkConfiguration
    
    func makeManager() -> ResourceManager {
        let builder = configuration.builder ?? NetworkRequestBuilder(configuration: .init(
            baseUrl: configuration.baseURL,
            headers: configuration.headers
        ))
        
        let dispatcher = configuration.dispatcher ?? NetworkDispatcher(configuration: .init(
            builder: builder,
            session: configuration.session
        ))
        
        return ResourceManager(configuration: .init(
            dispatcher: dispatcher,
            responseParser: configuration.responseParser
        ))
    }
}

struct NetworkConfiguration {
    
    let id: String
    
    /// The base URL for the environment
    let baseURL: URL
    
    /// Here we can put the default headers that we need for all requests
    let headers: [String: String]
    
    let responseParser: ResponseParserType = ResponseParser()
    let session: NetworkSessionType = URLSession()
    
    let builder: NetworkRequestBuilderType?
    let dispatcher: NetworkDispatcherType?
}
