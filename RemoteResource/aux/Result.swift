//
//  Service.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

enum Result<Success> {
    case success(Success)
    case failure(Error)
}
