//
//  URLRequestBuilder.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol URLRequestBuilder {

    var configuration: Configuration { get }

    func buildUrlFor(request: ResourceRequest) -> URLRequest?
}


struct URLRequestBuilderDefault: URLRequestBuilder {

    let configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }

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
            return URLHelper().escapedParameters(parameters)
            
        default:
            return path
        }
    }
    
    private func bodyParametersFor(parameters: RequestParameters) -> Data? {
        guard case .body(let parameters) = parameters else { return nil }
        return try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
    
    private func getURLFor(path: String) -> URL? {
        let string = configuration.baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding ?? ""
        guard let requestUrl = URL(string: string) else {
            return nil
        }
        
        return requestUrl
    }
}
