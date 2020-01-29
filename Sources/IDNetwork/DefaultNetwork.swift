//
//  DefaultNetwork.swift
//  
//
//  Created by Ivan Dilchovski on 23.10.19.
//

import Foundation
import PromiseKit

extension CancellablePromise where T == (HTTPURLResponse, Data) {
    func decoded<TypeToDecode: Decodable>(_ type: TypeToDecode.Type, decoder: JSONDecoder) -> CancellablePromise<(TypeToDecode, HTTPURLResponse)> {
        return self.map({ (response, data) in
            let decoded = try decoder.decode(type, from: data)
            return (decoded, response)
        })
    }
}

extension Promise where T == (HTTPURLResponse, Data) {
    func decoded<TypeToDecode: Decodable>(_ type: TypeToDecode.Type, decoder: JSONDecoder) -> Promise<(TypeToDecode, HTTPURLResponse)> {
        return self.map({ (response, data) in
            let decoded = try decoder.decode(type, from: data)
            return (decoded, response)
        })
    }
}

public class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    public init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    public func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder = JSONDecoder()) -> CancellablePromise<(T, HTTPURLResponse)> {
        return provider.request(endpoint: endpoint)
            .decoded(T.self, decoder: decoder)
    }
    
    public func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse> {
        return provider.request(endpoint: endpoint)
            .map({ (response, _) in return response })
    }
}
