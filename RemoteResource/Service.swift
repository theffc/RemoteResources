//
//  Service.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

/// Defines the environment configuration to be extracted
/// from our configution files (normally Plists)
public struct Configuration {
    
    /// Defines the environment name, ie. Production, Staging, Dev and so on
    let name: String
    
    /// Here we can put the default headers that we need for all requests
    let headers: [String: String]
    
    /// The base URL for the dispatcher
    let baseURL: URL
    
    /// Initialzer, that sets the initial values and starts the MASFoundation instance with the givend configurations
    ///
    /// - Parameters:
    ///   - name: the enviroment
    ///   - headers: the default headers for the environment
    public init(name: String, headers: [String: String]? = nil, baseURL: URL) {
        self.name = name
        self.headers = headers ?? [:]
        self.baseURL = baseURL
    }
    
}

enum Result<Success> {
    case success(Success)
    case failure(Error)
}

//NetworkManager -> NetworkingOperation(Resource) -> NetworkDispatcher
//
//NetworkManager.execute(NetworkingOperation())

protocol NetworkManager {
    
    var dispatcher: NetworkDispatcher { get }
    
    init(dispatcher: NetworkDispatcher)
    
    @discardableResult
    func execute<Resource: RemoteResource>(
        request: Resource.Request,
        completion: @escaping (NetworkResponseTyped<Resource.Response>) -> Void
    ) -> Resource
}


struct NetworkResponseTyped<Response: ResourceResponse> {
    
    let networkResponse: NetworkResponse
    let typedResponse: Result<Response>
}

extension NetworkManager {
    
    @discardableResult
    func execute<Resource: RemoteResource>(
        request: Resource.Request,
        completion: @escaping (NetworkResponseTyped<Resource.Response>) -> Void
    ) -> Resource?
    {
        dispatcher.dispatch(request: request) {
            let typedResponse: Result<Resource.Response>
            if case .respondedWithSuccess(let http) = $0.state {
                typedResponse = ResourceParserDefault().parseResponse(http)
            } else {
                // TODO: maybe handle this error differently
                typedResponse = .failure(NSError())
            }
            
            completion(.init(networkResponse: $0, typedResponse: typedResponse))
        }
        
        return nil
    }
}

protocol ResourceParser {

    func parseResponse<Response: ResourceResponse>(
        _ response: NetworkResponse.HttpResponse
    ) -> Result<Response>
}

struct ResourceParserDefault: ResourceParser {

    func parseResponse<Response: ResourceResponse>(
        _ response: NetworkResponse.HttpResponse
    ) -> Result<Response>
    {
        
    }
}
