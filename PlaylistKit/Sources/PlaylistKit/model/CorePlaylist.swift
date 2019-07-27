//
//  CorePlaylist.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation

public struct CorePlaylist: Codable {
    
    public init(name: String?, itemCount: Int, localPlaylistIdentifier: UInt64) {
        self.name = name
        self.itemCount = itemCount
        self.localPlaylistIdentifier = localPlaylistIdentifier
    }
    public var name: String?
    public var artwork: Data?
    public var itemCount: Int = 0
    public let identifier: UUID = UUID()
    public let localPlaylistIdentifier: UInt64
}
