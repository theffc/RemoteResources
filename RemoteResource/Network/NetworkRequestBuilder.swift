//
//  NetworkRequestBuilder.swift
//  RemoteResource
//
//  Created by Frederico Franco on 30/05/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol NetworkRequestBuilderType {

    var configuration: NetworkRequestBuilderConfig { get }

    func buildUrlFor(request: ResourceRequest) -> URLRequest?
}

public struct NetworkRequestBuilderConfig {

    let baseUrl: URL
    let headers: [String: String]
}

struct NetworkRequestBuilder: NetworkRequestBuilderType {
    
    let configuration: NetworkRequestBuilderConfig
}

// MARK: - Extension

public extension NetworkRequestBuilderType {
    
    func buildUrlFor(request: ResourceRequest) -> URLRequest? {
        let path = pathFor(parameters: request.parameters, path: request.path)
        let parameters = bodyParametersFor(parameters: request.parameters)
        let headers = httpHeadersFor(optionalHeaders: request.headers)
        
        guard let url = getURLFor(path: path) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = parameters
        
        return urlRequest
    }
    
    // MARK: - Helpers
    
    private func getURLFor(path: String) -> URL? {
        let string = configuration.baseUrl.appendingPathComponent(path).absoluteString.removingPercentEncoding ?? ""
        guard let requestUrl = URL(string: string) else {
            return nil
        }
        
        return requestUrl
    }
    
    private func httpHeadersFor(
        optionalHeaders: [String: String]?
    ) -> [String: String]
    {
        var headers = [String: String]()
        
        configuration.headers.forEach { (key, value) in
            headers[key] = value
        }
       
        optionalHeaders?.forEach { (key, value) in
            headers[key] = value
        }
        
        return headers
    }
    
    private func pathFor(parameters: RequestParameters, path: String) -> String {
        switch parameters {
        case .url(let parameters):
            return UrlHelper().stringWithSafelyEncodedParameters(parameters)
            
        default:
            return path
        }
    }
    
    private func bodyParametersFor(parameters: RequestParameters) -> Data? {
        guard case .body(let parameters) = parameters else { return nil }
        return try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
    
}
