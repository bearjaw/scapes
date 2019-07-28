//
//  CorePlaylistItem.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation

public struct CorePlaylistItem: Codable {
    
    public init(title: String?, album: String?, artist: String?, localPlaylistIdentifier: UInt64, index: Int, playCount: Int) {
        self.title = title ?? "Unknown"
        self.album = album ?? "Unknown"
        self.artist = artist ?? "Unknown"
        self.index = index
        self.playCount = playCount
        self.localPlaylistIdentifier = localPlaylistIdentifier
    }
    
    public let index: Int
    public var title: String
    public var album: String
    public var artist: String
    public var artwork: Data?
    public var playCount: Int = 0
    public let identifier: UUID = UUID()
    public let localPlaylistIdentifier: UInt64
}
