//
//  Network.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

public protocol Network {
    func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder) -> CancellablePromise<T>
    func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse>
}

public class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    public init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    public func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder) -> CancellablePromise<T> {
        return provider.request(endpoint: endpoint)
            .map({ _, data in
                return try decoder.decode(T.self, from: data)
            })
    }
    
    public func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse> {
        return provider.request(endpoint: endpoint)
            .map({ (response, _) in return response })
    }
}
