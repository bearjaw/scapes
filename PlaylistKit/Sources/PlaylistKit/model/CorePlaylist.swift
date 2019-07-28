//
//  CorePlaylist.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation

public struct CorePlaylist: Codable {
    
    public init(identifier: UUID = UUID(), name: String?, itemCount: Int, localPlaylistIdentifier: UInt64) {
        self.name = name ?? "Unknown"
        self.itemCount = itemCount
        self.identifier = identifier
        self.localPlaylistIdentifier = localPlaylistIdentifier
    }
    
    public var name: String
    public var artwork: Data?
    public var itemCount: Int = 0
    public let identifier: UUID
    public let localPlaylistIdentifier: UInt64
}
