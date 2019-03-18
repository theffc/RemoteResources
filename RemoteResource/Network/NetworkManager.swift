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
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseTyped<Resource.Response>) -> Void
    )
}


// TODO: refactor this struct to be an enum with improved semantics
struct NetworkResponseTyped<Response: ResourceResponse> {
    
    let networkResponse: NetworkResponse
    let typedResponse: Result<Response>
}

class NetworkManagerDefault: NetworkManager {
    
    let dispatcher: NetworkDispatcher
    
    init(dispatcher: NetworkDispatcher) {
        self.dispatcher = dispatcher
    }
    
    func request<Resource: RemoteResource>(
        resource: Resource,
        completion: @escaping (NetworkResponseTyped<Resource.Response>) -> Void
    ) {
        dispatcher.dispatch(request: resource.request) {
            let typedResponse: Result<Resource.Response>
            
            // TODO: should handle error properly
            
            if case .didReceiveResponse(let response) = $0.state {
                if let error = response.error {
                    typedResponse = .failure(error)
                } else {
                    typedResponse = ResponseParserDefault().parseResponse(response)
                }
            } else {
                typedResponse = .failure(NSError())
            }
            
            completion(.init(networkResponse: $0, typedResponse: typedResponse))
        }
    }
}
