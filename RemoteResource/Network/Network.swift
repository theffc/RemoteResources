//
//  Network.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

struct NetworkingError: Error {
    
}

struct NetworkingResponse {
    
    let request: ResourceRequest
    let httpResponse: HTTPURLResponse?
    
    let result: Result<Data>
}


protocol NetworkDispatcher {
    
    typealias Completion = (NetworkingResponse) -> Void
    
    init(configuration: Configuration)
    
    func dispatch(request: ResourceRequest, completion: @escaping Completion)
}
