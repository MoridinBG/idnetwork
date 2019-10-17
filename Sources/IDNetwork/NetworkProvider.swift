//
//  NetworkProvider.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

public protocol NetworkProvider {
    func request(endpoint: Endpoint) -> CancellablePromise<(HTTPURLResponse, Data)>
}

public enum NetworkError: Error {
    case statusCode(Int)
    case badResponse
    case badRequest
    case noConnection
    case error(Error)
}
