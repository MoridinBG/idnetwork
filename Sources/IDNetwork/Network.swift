//
//  Network.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

public protocol Network {
    func request<T: Decodable>(endpoint: Endpoint) -> CancellablePromise<T>
    func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse>
}

public class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    public init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    public func request<T: Decodable>(endpoint: Endpoint) -> CancellablePromise<T> {
        return provider.request(endpoint: endpoint)
            .then({ (_, data)  in
                return Promise { resolver in
                    let model = try JSONDecoder().decode(T.self, from: data)
                    resolver.fulfill(model)
                }
            })
    }
    
    public func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse> {
        return provider.request(endpoint: endpoint)
            .map({ (response, _) in return response })
    }
}
