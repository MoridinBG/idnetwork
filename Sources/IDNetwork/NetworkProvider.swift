//
//  NetworkProvider.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import Combine

public protocol NetworkProvider {
    func request(endpoint: Endpoint) -> AnyPublisher<(Data, HTTPURLResponse), NetworkError>
    func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder) -> AnyPublisher<(T, HTTPURLResponse), NetworkError>
    
}

public enum NetworkError: Error {
    case statusCode(Int)
    case badResponse(URLError.Code?)
    case badRequest(URLError.Code?)
    case decodingFailed(Error)
    case noConnection(URLError.Code?)
    case authentication(URLError.Code?)
    case timeout
    case other(URLError?)
}
