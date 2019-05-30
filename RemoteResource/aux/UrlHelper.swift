//
//  UrlHelper.swift
//  RemoteResource
//
//  Created by Frederico Franco on 30/05/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

struct UrlHelper {
    
    func stringWithSafelyEncodedParameters(_ parameters: [String: Any]) -> String {
        guard !parameters.isEmpty else { return "" }
        
        var result = [String]()
        for (key, value) in parameters {
            let string = "\(value)"
            
            guard let treated = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                assertionFailure(); continue
            }
            
            result.append("\(key)=\(treated)")
        }
        
        return "?\(result.joined(separator: "&"))"
    }
}
