//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

protocol NetworkProvider {
    func request(endpoint: Endpoint) -> Promise<(HTTPURLResponse, Data)>
}

enum NetworkError: Error {
    case statusCode(Int)
    case badResponse
    case noConnection
    case error(Error)
}

protocol NetworkRequest {
    func resume()
    func suspend()
    func cancel()
}
