//
//  AppError.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation

enum AppError: LocalizedError {
    
    case badURL
    case networkError(Error)
    case noResponse
    case decodingError(Error)
    case badStatusCode(String)
    case noBarcodeFound
    case processingError(Error)
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return NSLocalizedString("The current URL provided is invalid", comment: "Indicates to the user that their URL is invalid.")
        case .networkError(let error):
            return NSLocalizedString("There was an error with the network \(error)", comment: "Indicates to the user that there is a network error.")
        case .noResponse:
            return NSLocalizedString("There was no respinse from the network.", comment: "Indicates to the user there was no network response.")
        case .decodingError(let error):
            return NSLocalizedString("A decoding error occured. \(error)", comment: "Indicates to the user that a decoding error occured")
        case .badStatusCode(let message):
            return NSLocalizedString("A bad status code occured \(message)", comment: "Indicates to there is a bad status code.")
        case .noBarcodeFound:
            return NSLocalizedString("No barcode was found", comment: "Indicates to the user no barcode was found.")
        case .processingError(let error):
            return NSLocalizedString("An error was encounter when processing image \(error)", comment: "Indicates to the user that an error occured")
        case .productNotFound:
            return NSLocalizedString("This product could not be found", comment: "Informs the user that the product could not be found.")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .badURL:
            return ""
        case .networkError:
            return NSLocalizedString("Check your network connection and try again", comment: "Informs the user that they should check their connection.")
        case .noResponse:
            return NSLocalizedString("There was no respinse from the network.", comment: "Indicates to the user there was no network response.")
        case .decodingError:
            return NSLocalizedString("Check the expected type.", comment: "Indicates to the user that a decoding error occured")
        case .badStatusCode:
            return NSLocalizedString("Check your connection and try again.", comment: "Informs the user they should check their connection.")
        case .noBarcodeFound, .processingError, .productNotFound:
            return NSLocalizedString("Try scanning another barcode.", comment: "Informs the user that they should try scanning another barcode.")
        }
    }
}
