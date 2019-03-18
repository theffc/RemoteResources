//
//  Parser.swift
//  RemoteResource
//
//  Created by Frederico Franco on 18/03/19.
//  Copyright © 2019 theffc. All rights reserved.
//

import Foundation

protocol ResponseParser {

    func parseResponse<Response: ResourceResponse>(
        _ response: NetworkResponse.HttpResponse
    ) -> Result<Response>
}

struct ResponseParserDefault: ResponseParser {

    func parseResponse<Response: ResourceResponse>(
        _ response: NetworkResponse.HttpResponse
    ) -> Result<Response>
    {
        // TODO: implement function
        return .failure(NSError())
    }
}
