//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

extension URLSessionTask: NetworkRequest {}

class URLSessionNetworkProvider: NetworkProvider {
    fileprivate let session: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    func request(endpoint: Endpoint) -> Promise<(HTTPURLResponse, Data)> {
        return Promise { resolver in
            let task = session.dataTask(with: endpoint.request) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        if let error = error as NSError? {
                            if error.domain == NSURLErrorDomain && error.code < -1001 && error.code > -1011  {
                                resolver.reject(NetworkError.noConnection)
                            } else {
                                resolver.reject(NetworkError.error(error))
                            }
                        } else {
                            resolver.reject(NetworkError.badResponse)
                        }
                        return
                    }
                    
                    guard response.statusCode >= 200 && response.statusCode < 300 else {
                        resolver.reject(NetworkError.statusCode(response.statusCode))
                        return
                    }

                    resolver.fulfill((response, data))
                }
            }

            task.resume()
        }
    }
}
