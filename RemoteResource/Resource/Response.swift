//
//  Response.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol ResourceResponse: Decodable {

    var validation: ValidationType { get }
}

/// Represents the status codes to validate through Alamofire.
enum ValidationType {
    
    /// No validation.
    case none
    
    /// Validate success codes (only 2xx).
    case successCodes
    
    /// Validate success codes and redirection codes (only 2xx and 3xx).
    case successAndRedirectCodes
    
    /// Validate only the given status codes.
    case customCodes([Int])
}

extension ValidationType {
    
    func validateStatusCode(_ statusCode: Int) -> Bool {
        switch self {
        case .none:
            return true
        
        case .successCodes:
            return isValidSuccessCode(statusCode)
        
        case .successAndRedirectCodes:
            return isValidSuccessCode(statusCode)
                   && isRedirectCode(statusCode)
        
        case .customCodes(let range):
            return range.contains(statusCode)
        }
    }
    
    func isValidSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode <= 299
    }
    
    func isRedirectCode(_ statusCode: Int) -> Bool {
        return statusCode >= 300 && statusCode <= 399
    }
}
