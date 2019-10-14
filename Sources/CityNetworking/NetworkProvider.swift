//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation

protocol NetworkProvider {
    func request(endpoint: Endpoint, dataHandler: @escaping (_ result: Result<(HTTPURLResponse, Data), NetworkProviderError>) -> ()) -> NetworkRequest
    func request(endpoint: Endpoint, responseHandler: @escaping (_ result: Result<HTTPURLResponse, NetworkProviderError>) -> ()) -> NetworkRequest
}

enum NetworkProviderError: Error {
    case badResponse
    case noConnection
    case error(Error)
}

protocol NetworkRequest {
    func resume()
    func suspend()
    func cancel()
}
