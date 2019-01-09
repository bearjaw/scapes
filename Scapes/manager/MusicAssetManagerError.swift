//
//  MusicAssetManagerError.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import Foundation

enum MusicAssetManagerError: Error {
    case network(NetworkError?)
    case invalidResponseType
    case emptyResponse
    case unexpectedResponse(HTTPURLResponse, String?)
}
