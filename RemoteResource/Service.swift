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

//ServiceManager -> NetworkingOperation(Resource) -> NetworkDispatcher
//
//ServiceManager.execute(NetworkingOperation())

protocol ServiceManager {
    
    func execute()
}

protocol ResourceOperation {
    
    associatedtype Resource: RemoteResource
    
    typealias Completion = (Result<Resource.Response>) -> Void
    
    func execute(
        request: Resource.Request,
        in dispatcher: NetworkDispatcher,
        completion: @escaping Completion
    )
}

struct NetworkingOperation<Resource: RemoteResource> {
    
    ///
    public typealias Completion = (Result<Resource.Response>) -> Void
    
    /// The request to be executed
    let request: Resource.Request
    
    /// Initialization
    ///
    /// - Parameter request: The request for this operation
    public init(request: Resource.Request) {
        self.request = request
    }
    
    /// Execute an request operation
    ///
    /// - Parameters:
    ///   - dispatcher: the dispatcher to perform requests
    ///   - completion: the result of the operation
    public func execute(in dispatcher: NetworkDispatcher, completion: @escaping Completion) {
        
        dispatcher.dispatch(request: request) { (response) in
            
            switch response.result {
            case .success(let data):
                // TODO: make response parsing
                break
            
            case .failure(let error):
                completion(.failure(error))
            
            }
//            switch response {
//            case .data(let data):
//
//                guard let data = data else {
//                    completion(nil, NetworkingError(internalError: .noData))
//                    return
//                }
//
//                do {
//                    let serializedResponse = try JSONDecoder().decode(ResponseType.self, from: data)
//                    completion(serializedResponse, nil)
//                } catch let error {
//                    completion(nil, NetworkingError(rawError: error))
//                }
//
//            case .error(let error): // TODO: Serialize error?
//                let networkingError: NetworkingError = error ?? NetworkingError(internalError: .unknown)
//                completion(nil, networkingError)
//            }
        }
        
    }
    
}



