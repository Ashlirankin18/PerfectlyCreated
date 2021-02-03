//
//  Result+Combine.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/3/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    
    /// A single value sink function that coalesces either one `Output` or one `Failure` as a `Result`-type.
    public func sink(result: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
        return sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                    result(.failure(error))
            case .finished:
                    break
            }
        }, receiveValue: { output in
            result(.success(output))
        })
    }
}
