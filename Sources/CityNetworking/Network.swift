//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation

protocol Network {
    func request<T: Codable>(endpoint: Endpoint,
                 handler: ((Result<T, Error>) -> ())?) -> NetworkRequest
}

class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    func request<T: Codable>(endpoint: Endpoint,
                             handler: ((Result<T, Error>) -> ())?) -> NetworkRequest {

        return provider.request(endpoint: endpoint, responseHandler: { result in
            switch result {
            case .failure(let error):
                handler?(Result.failure(error))

            case .success(let urlResponse):
                break
            }
        })
    }
}
