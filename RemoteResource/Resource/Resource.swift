//
//  Resource.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol RemoteResource {

    associatedtype Request: ResourceRequest
    associatedtype Response: ResourceResponse
    
    var sampleResponse: Response { get }
}
