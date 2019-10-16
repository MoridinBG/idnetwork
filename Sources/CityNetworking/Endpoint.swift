//
//  File.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String : Any]? { get }
    var encoding: NetworkRequestParameterEncoding { get }
    var headers: [String : String]? { get }
}

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

public enum NetworkRequestParameterEncoding {
    case json
    case url
}
