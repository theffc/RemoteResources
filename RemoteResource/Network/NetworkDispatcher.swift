//
//  NetworkDispatcher.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol NetworkDispatcher {
    
    typealias Completion = (NetworkResponse) -> Void
    
    var configuration: NetworkConfiguration { get }
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion)
}
