//
//  DefaultNetwork.swift
//  
//
//  Created by Ivan Dilchovski on 23.10.19.
//

import Foundation
import PromiseKit

extension CancellablePromise where T == (HTTPURLResponse, Data) {
    func decoded<TypeToDecode: Decodable>(_ type: TypeToDecode.Type, decoder: JSONDecoder) -> CancellablePromise<TypeToDecode> {
        return self.map({ (response, data) -> TypeToDecode in
            return try decoder.decode(type, from: data)
        })
    }
}

extension Promise where T == (HTTPURLResponse, Data) {
    func decoded<TypeToDecode: Decodable>(_ type: TypeToDecode.Type, decoder: JSONDecoder) -> Promise<TypeToDecode> {
        return self.map({ (response, data) -> TypeToDecode in
            return try decoder.decode(type, from: data)
        })
    }
}

public class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    public init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    public func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder = JSONDecoder()) -> CancellablePromise<T> {
        return provider.request(endpoint: endpoint)
            .decoded(T.self, decoder: decoder)
    }
    
    public func request(endpoint: Endpoint) -> CancellablePromise<HTTPURLResponse> {
        return provider.request(endpoint: endpoint)
            .map({ (response, _) in return response })
    }
}
