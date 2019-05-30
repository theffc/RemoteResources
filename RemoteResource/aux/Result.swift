//
//  Service.swift
//  RemoteResource
//
//  Created by Frederico Franco on 14/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

public enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)
}
