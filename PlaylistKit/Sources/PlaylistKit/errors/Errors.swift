//
//  File.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation
import ErrorKit

public enum AccessError: Loggable {
    case notDetermined
    case denied
    case restricted
    case unknown
    
    public var reason: String {
        switch self {
        case .notDetermined:
            return "Could not determine auth status"
        case .denied:
            return "Access to media library is denied"
        case .restricted:
            return "Access to media library is restricted"
        case .unknown:
            return "Unknown error occured."
        }
    }
}

public enum MusicKitError: Loggable {
    case notFound(UInt64)
    case unknown
    
    public var reason: String {
        switch self {
        case .notFound(let identifer):
            return "Could not find item for identifier \(identifer)"
        case .unknown:
            return "Unknown error occured."
        }
    }
}
