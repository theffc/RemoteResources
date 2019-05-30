//
//  ResponseValidation.swift
//  RemoteResource
//
//  Created by Frederico Franco on 15/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

/// Represents the status codes to validate through Alamofire.
public enum ValidationType {
    
    /// No validation.
    case none
    
    /// Validate success codes (only 2xx).
    case successCodes
    
    /// Validate success codes and redirection codes (only 2xx and 3xx).
    case successAndRedirectCodes
    
    /// Validate only the given status codes.
    case customCodes([Int])
}

public extension ValidationType {
    
    func isValidStatusCode(_ statusCode: Int) -> Bool {
        switch self {
        case .none:
            return true
        
        case .successCodes:
            return isSuccessCode(statusCode)
        
        case .successAndRedirectCodes:
            return isSuccessCode(statusCode)
                   && isRedirectCode(statusCode)
        
        case .customCodes(let range):
            return range.contains(statusCode)
        }
    }
    
    func isSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode <= 299
    }
    
    func isRedirectCode(_ statusCode: Int) -> Bool {
        return statusCode >= 300 && statusCode <= 399
    }
}
