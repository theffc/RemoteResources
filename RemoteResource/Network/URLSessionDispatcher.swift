//
//  URLSessionDispatcher.swift
//  Networking
//
//  Created by Eduardo Bocato on 23/01/19.
//  Copyright © 2019 Eduardo Bocato. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol {

    func dataTask(
        with request: NSURLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

// MARK: URLSessionDataTaskProtocol
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: - URLSessionProtocol
extension URLSession: URLSessionProtocol {

    public func dataTask(
        with request: NSURLRequest,
        completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
    {
        let urlRequest = request
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        return task as URLSessionDataTaskProtocol
    }
}

public class URLSessionDispatcher: NetworkDispatcher {
    
    // MARK: - Properties
    
    public let configuration: Configuration
    private var session: URLSessionProtocol = URLSession.shared
    
    // MARK: - Initialization
    
    public required init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public required init(configuration: Configuration, session: URLSessionProtocol = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Dispatch
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion) {
        let path = pathFor(parameters: request.parameters, path: request.path)
        let parameters = bodyParametersFor(parameters: request.parameters)
        let headers = httpHeadersFor(optionalHeaders: request.headers)
        
        guard let urlRequest = self.buildURLRequest(
            httpMethod: request.method,
            url: configuration.baseURL,
            path: path,
            payload: parameters,
            headers: headers
        ) else {
            completion(NetworkResponse(
                // TODO: improve error handling
                request: request, state: .couldNotResolveResource
            ))
            return
        }
        
        let task = session.dataTask(with: urlRequest as NSURLRequest) {
            (data, response, error) in
            
            let state = self.responseStateFor(data: data, response: response, error: error)
            
            let response = NetworkResponse(
                request: request, state: state
            )
            
            completion(response)
        }
        
        task.resume()
    }
    
    func responseStateFor(
        data: Data?, response: HTTPURLResponse?, error: Error?
    ) -> NetworkResponse.State
    {
        switch (data, response, error) {
            
        case (let data?, let response?, nil):
            return .respondedWithSuccess(.init(
                httpResponse: response, data: data
            ))
            
        case (let data?, let response?, let error?):
            return .respondedWithError(.init(
                response: .init(httpResponse: response, data: data),
                error: error
            ))
            
        case (nil, nil, let error?):
            return .networkError(error)
            
        default:
            assertionFailure("this case should not happen, in case it happens, you should add a new state in the NetworkResponse")
            return .networkError(NSError())
        }
    }
    
}

extension URLSessionDispatcher {
    
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
    
    private func buildURLRequest(
        httpMethod: HTTPMethod,
        url: URL,
        path: String?,
        payload: Data? = nil,
        headers: [String:String]? = nil
    ) -> URLRequest?
    {
        var requestURL = url
        if let path = path {
            let fullURL = self.getURL(with: path)
            
            guard let uri = fullURL else {
                return nil
            }
            
            requestURL = uri
        }
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = payload
        
        return request
    }
    
    private func getURL(with path: String) -> URL? {
        guard let urlString = configuration.baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding,
              let requestUrl = URL(string: urlString) else {
            return nil
        }
        return requestUrl
    }
    
}


class URLHelper {
    
    func escapedParameters(_ parameters: [String: Any]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            for (key, value) in parameters {
                // make sure that it is a string value
                let stringValue = "\(value)"
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
}
