//
//  Resource.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

/// It's the api of your Resource; describes input and output.
public protocol RemoteResource {

    associatedtype Request: ResourceRequest
    associatedtype Response: ResourceResponse
    
    var request: Request { get }
    
    var sampleResponse: Response { get }
    
    var validation: ValidationType { get }
}
