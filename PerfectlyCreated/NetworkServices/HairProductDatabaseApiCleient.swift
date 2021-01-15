//
//  HairProductDatabaseApiCleient.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

final class HairProductApiClient {
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var networkHelper = NetworkHelper()
    
    /// Retrieves the hair products from the api.
    /// - Returns: Publisher containing the returned hair products and a possible error.
    func getHairProducts() -> AnyPublisher<[AllHairProducts], AppError>? {
        let urlString = "http://5c671eba24e2140014f9ee6d.mockapi.io/api/v1/hairProducts"
        guard let url = URL(string: urlString) else {
            assertionFailure("URL invalid")
            return nil
        }
        return genericRetrievalMethod(with: url, httpMethod: "GET")
            .map { $0 as [AllHairProducts] }
            .eraseToAnyPublisher()
    }
    
    /// Retrieves a product from the server
    /// - Parameter barcodeNumber: The bar code of the product.
    /// - Returns: Publisher containing the returned hair product and a possible error.
    func retrieveHairProduct(with barcodeNumber: String) -> AnyPublisher<HairProduct, AppError>? {
        let urlString = "https://api.barcodespider.com/v1/lookup?token=229820d4f6a2509d2307&upc=\(barcodeNumber)"
        
        guard let url = URL(string: urlString) else {
            assertionFailure("URL invalid")
            return nil
        }
        return genericRetrievalMethod(with: url, httpMethod: "GET")
            .map { $0 as HairProduct }
            .eraseToAnyPublisher()
    }
    
    private func genericRetrievalMethod<T: Codable>(with url: URL, httpMethod: String, httpBody: Data? = nil ) -> AnyPublisher<T, AppError> {
        
        let passThroughSubject = PassthroughSubject<T, AppError>()
        
        networkHelper.performDataTask(endpointURL: url, httpMethod: httpMethod, httpBody: httpBody)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case let .failure(error):
                        passThroughSubject.send(completion: .failure(.networkError(error)))
                    case . finished:
                        passThroughSubject.send(completion: .finished)
                }
            }, receiveValue: { data in
                do {
                    let genericProduct = try JSONDecoder().decode(T.self, from: data)
                    passThroughSubject.send(genericProduct)
                } catch {
                    passThroughSubject.send(completion: .failure(.decodingError(error)))
                }
            })
            .store(in: &cancellables)
        
        return passThroughSubject.eraseToAnyPublisher()
    }
}
