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
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
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
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
    {
        let urlRequest = request as URLRequest
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
        let path = pathFor(request: request)
        let parameters = bodyParametersFor(request: request)
        let headers = headersFor(request: request)
        
        guard let urlRequest = self.buildURLRequest(
            httpMethod: request.method,
            url: configuration.baseURL,
            path: path,
            payload: parameters,
            headers: headers
        ) else {
            completion(NetworkingResponse(
                // TODO: improve error handling
                request: request, httpResponse: nil, result: .failure(NetworkingError())
            ))
            return
        }
        
        let task = session.dataTask(with: urlRequest as NSURLRequest) {
            (data, urlResponse, error) in
            let httpResponse = urlResponse as? HTTPURLResponse
            
            let result: Result<Data>
            switch (data, error) {
            case (let data?, nil):
                result = .success(data)
            default:
                // TODO: improve error handling
                result = .failure(NetworkingError())
            }
            
            let response = NetworkingResponse(
                request: request,
                httpResponse: httpResponse,
                result: result
            )
            
            completion(response)
        }
        
        task.resume()
    }
    
}

extension URLSessionDispatcher {
    
    // MARK: - Helpers
    private func headersFor(request: ResourceRequest) -> [String: String] {
        
        var headers = [String: String]()
        
        configuration.headers.forEach { (key, value) in
            headers[key] = value
        }
       
        request.headers?.forEach { (key, value) in
            headers[key] = value
        }
        
        return headers
    }
    
    private func pathFor(request: ResourceRequest) -> String {
        switch request.parameters {
        case .url(let parameters):
            return URLHelper().escapedParameters(parameters)
            
        default:
            return request.path
        }
    }
    
    private func bodyParametersFor(request: ResourceRequest) -> Data? {
        guard case .body(let parameters) = request.parameters else { return nil }
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
