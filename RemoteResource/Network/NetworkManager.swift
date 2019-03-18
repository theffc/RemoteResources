//
//  NetworkManager.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol NetworkManager {
    
    var dispatcher: NetworkDispatcher { get }
    
    var responseParser: ResponseParser { get }
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseForResource<Resource>) -> Void
    )
}

class NetworkManagerDefault: NetworkManager {
    
    let input: Input
    
    struct Input {
        let dispatcher: NetworkDispatcher
        let responseParser: ResponseParser
    }
    
    init(input: Input) {
        self.input = input
    }
    
    var dispatcher: NetworkDispatcher { return input.dispatcher }
    var responseParser: ResponseParser { return input.responseParser }
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseForResource<Resource>) -> Void
    ) {
        typealias ReturnType = NetworkResponseForResource<Resource>
    
        input.dispatcher.dispatch(request: resource.request) {
            let result: Result<ReturnType.Response, ReturnType.Error>
            
            switch $0.response {
            case .success(let http):
                let parserResult: Result<Resource.Response, ResponseParserError> =
                    self.input.responseParser.parseResponse(http)
                
                switch parserResult {
                case .success(let parsed):
                    result = .success(.init(typed: parsed, http: http))
                case .failure(let error):
                    result = .failure(.parser(error))
                }
            
            case .failure(let error):
                result = .failure(.network(error))
            }
            
            completion(.init(request: resource.request, response: result))
        }
    }
}
