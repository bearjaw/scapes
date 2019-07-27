//
//  CorePlaylistItem.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation

public class CorePlaylistItem: Codable {
    
    public init(title: String, album: String?, artist: String) {
        self.title = title
        self.album = album
        self.artist = artist
    }
    
    public var title: String
    public var album: String?
    public var artist: String
    public let identifier: UUID = UUID()
    public var playCount: Int = 0
}
