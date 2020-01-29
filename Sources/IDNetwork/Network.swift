//
//  Network.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

public protocol Network {
    func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder) -> CancellablePromise<(T, HTTPURLResponse)>
    func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse>
}
