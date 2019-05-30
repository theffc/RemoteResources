//
//  NetworkManager.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol NetworkManagerType {

    var configuration: NetworkManagerConfiguration { get }
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseForResource<Resource>) -> Void
    )
}

public struct NetworkManagerConfiguration {
    
    let dispatcher: NetworkDispatcherType
    let responseParser: ResponseParserType
}

public class NetworkManager: NetworkManagerType {
    
    public let configuration: NetworkManagerConfiguration
    
    init(configuration: NetworkManagerConfiguration) {
        self.configuration = configuration
    }
}

public extension NetworkManagerType {
    
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
    
    private func parseResponse<Resource: RemoteResource>(
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
