//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation

protocol Network {
    func request<T: Codable>(endpoint: Endpoint,
                 handler: @escaping (Result<T, NetworkError>) -> ()) -> NetworkRequest
}

enum NetworkError: Error {
    case statusCode(Int)
    case other(Error)
}

class DefaultNetwork: Network {
    private let provider: NetworkProvider
    
    init(provider: NetworkProvider = URLSessionNetworkProvider()) {
        self.provider = provider
    }
    
    func request<T: Codable>(endpoint: Endpoint,
                             handler: @escaping (Result<T, NetworkError>) -> ()) -> NetworkRequest {

        return provider.request(endpoint: endpoint, dataHandler: { result in
            switch result {
            case .failure(let error):
                handler(Result.failure(.other(error)))

            case .success(let (response, data)):
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    handler(Result.failure(.statusCode(response.statusCode)))
                    return
                }
                
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    handler(Result.success(model))
                } catch {
                    handler(Result.failure(.other(error)))
                }
            }
        })
    }
}
