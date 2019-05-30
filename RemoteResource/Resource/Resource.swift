//
//  Resource.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public protocol RemoteResource {

    associatedtype Request: ResourceRequest
    associatedtype Response: ResourceResponse
    
    var request: Request { get }
    
    var sampleResponse: Response { get }
    
    var validation: ValidationType { get }
}
