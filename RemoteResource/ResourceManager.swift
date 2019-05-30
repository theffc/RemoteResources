//
//  ResourceManager.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

// TODO: configure it to make it possible to return just the sample response from the Resource.

/// Manages the request and response for a particular Resource.
/// You should be using it as the primary api of your services.
public protocol ResourceManagerType {

    var configuration: ResourceManagerConfiguration { get }
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseForResource<Resource>) -> Void
    )
}

public struct ResourceManagerConfiguration {
    
    let dispatcher: NetworkDispatcherType
    let responseParser: ResponseParserType
}

public class ResourceManager: ResourceManagerType {
    
    public let configuration: ResourceManagerConfiguration
    
    init(configuration: ResourceManagerConfiguration) {
        self.configuration = configuration
    }
}

public extension ResourceManagerType {
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseForResource<Resource>) -> Void
    ) {
        configuration.dispatcher.dispatch(request: resource.request) {
            let result: NetworkResponseForResource<Resource>.ResultType
            
            switch $0.result {
            case .success(let http):
                result = self.parseResponse(http, for: resource)
            
            case .failure(let error):
                result = .failure(.network(error))
            }
            
            completion(.init(request: resource.request, result: result))
        }
    }
    
    func parseResponse<Resource: RemoteResource>(
        _ httpResponse: NetworkResponse.Http,
        for resource: Resource
    ) -> NetworkResponseForResource<Resource>.ResultType
    {
        let parserResult = configuration.responseParser.parseResponse(httpResponse, for: resource)
        
        switch parserResult {
        case .success(let parsed):
            return .success(.init(typed: parsed, http: httpResponse))
        case .failure(let error):
            return .failure(.parser(.init(error: error, http: httpResponse)))
        }
    }
}
