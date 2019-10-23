//
//  URLSessionNetworkProvider.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import PromiseKit

extension URLSessionTask: Cancellable {
    public var isCancelled: Bool {
        return state != .running
    }
}


public class URLSessionNetworkProvider: NetworkProvider {
    fileprivate let session: URLSession

    public init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }
    
    public func request(endpoint: Endpoint) -> CancellablePromise<(HTTPURLResponse, Data)> {
        var task: URLSessionTask?
        var reject: ((Error) -> Void)?
        
        let promise: CancellablePromise<(HTTPURLResponse, Data)> = CancellablePromise { resolver in
            guard let request = endpoint.request else {
                resolver.reject(NetworkError.badRequest)
                return
            }
            reject = resolver.reject
            
            task = session.dataTask(with: request) { data, response, error in
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
            
            task!.resume()
        }
        
        if let task = task, let reject = reject {
            promise.appendCancellable(task, reject: reject)
        }
        
        return promise
    }
}
