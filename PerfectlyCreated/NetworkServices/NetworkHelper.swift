//
//  NetworkHelper.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

/// Object which contains the networing logic.
final class NetworkHelper {
    
    /// Creates a new instance of `NetworkHelper`.
    init() {
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 10 * 1024 * 1024, diskPath: nil)
        URLCache.shared = cache
    }
    
    private var cancellables = Set<AnyCancellable>()
    /// Performs a data task.
    /// - Parameters:
    ///   - endpointURLString: The url end point.
    ///   - httpMethod: The HTTP Method
    ///   - httpBody: The http body.
    ///   - completionHandler: Called on completion
    func performDataTask(endpointURL: URL, httpMethod: String, httpBody: Data?) -> AnyPublisher<Data, AppError> {
        
        let passThroughSubject = PassthroughSubject<Data, AppError>()
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = httpMethod
        
        URLSession.shared.dataTaskPublisher(for: request)
            .sink { completion in
                switch completion {
                case let .failure(error):
                        passThroughSubject.send(completion: .failure(.networkError(error)))
                case  .finished:
                        passThroughSubject.send(completion: .finished)
                }
            } receiveValue: { result in
                passThroughSubject.send(result.data)
            }
            .store(in: &cancellables)
        return passThroughSubject.eraseToAnyPublisher()
    }
}
