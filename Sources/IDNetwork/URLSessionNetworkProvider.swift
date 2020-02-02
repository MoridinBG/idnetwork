//
//  URLSessionNetworkProvider.swift
//  
//
//  Created by Ivan Dilchovski on 14.10.19.
//

import Foundation
import Combine

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
    
    
    public func request(endpoint: Endpoint) -> AnyPublisher<(Data, HTTPURLResponse), NetworkError> {
        guard let request = endpoint.request else {
            return Fail<(Data, HTTPURLResponse), NetworkError>(error: .badRequest(nil)).eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: request)
            .mapError(NetworkError.init)
            .tryMap { data, response -> (Data, HTTPURLResponse) in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.badResponse(nil)
                    }
                    
                    guard 200..<300 ~= httpResponse.statusCode  else {
                        throw NetworkError.statusCode(httpResponse.statusCode)
                    }
                    
                    return (data, httpResponse)
            }.mapError { error -> NetworkError in
                guard let error = error as? NetworkError else {
                    assert(false, "Only NetworkErrors expected at this point")
                    return .other(nil)
                }
                return error
            }.eraseToAnyPublisher()
    }

    public func requestDecoded<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder) -> AnyPublisher<(T, HTTPURLResponse), NetworkError> {
        return request(endpoint: endpoint)
            .flatMap { data, response in
                return Just(data)
                    .decode(type: T.self, decoder: decoder)
                    .mapError { error -> NetworkError in
                        return .decodingFailed(error)
                }.zip(Just(response).setFailureType(to: NetworkError.self))
        }.eraseToAnyPublisher()
    }
}

extension NetworkError {
    init(_ urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet,
             .cannotFindHost,
             .cannotConnectToHost,
             .cannotLoadFromNetwork,
             .internationalRoamingOff,
             .dataNotAllowed,
             .networkConnectionLost,
             .secureConnectionFailed:
            self = .noConnection(urlError.code)
            
        case .timedOut:
            self = .timeout
            
        case .badURL,
             .unsupportedURL,
             .fileDoesNotExist,
             .fileIsDirectory,
             .noPermissionsToReadFile,
             .clientCertificateRejected,
             .clientCertificateRequired,
             .requestBodyStreamExhausted:
            self = .badRequest(urlError.code)
            
        case .badServerResponse,
             .httpTooManyRedirects,
             .resourceUnavailable,
             .redirectToNonExistentLocation,
             .zeroByteResource,
             .cannotDecodeRawData,
             .cannotDecodeContentData,
             .cannotParseResponse,
             .dataLengthExceedsMaximum,
             .serverCertificateHasBadDate,
             .serverCertificateUntrusted,
             .serverCertificateHasUnknownRoot,
             .serverCertificateNotYetValid,
             .downloadDecodingFailedMidStream,
             .downloadDecodingFailedToComplete:
            self = .badResponse(urlError.code)
            
        case .userCancelledAuthentication, .userAuthenticationRequired:
            self = .authentication(urlError.code)
            
        default:
            self = .other(urlError)
        }
    }
}
