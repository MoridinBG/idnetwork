//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

protocol Network {
    func request<T: Codable>(endpoint: Endpoint) -> Promise<T>
}

class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    func request<T: Codable>(endpoint: Endpoint) -> Promise<T> {
        provider.request(endpoint: endpoint)
            .then({ (response, data)  in
                return Promise { resolver in
                    let model = try JSONDecoder().decode(T.self, from: data)
                    resolver.fulfill(model)
                }
            })
    }
}
