//
//  CoreSongLink.swift
//  
//
//  Created by Max Baumbach on 28/07/2019.
//

import Foundation

public struct CoreSongLink: Codable, Hashable {
    
    public init(identifier: UInt64, appleURL: String, songLinkURL: String, title: String, artist: String, album: String, index: Int) {
        self.identifier = identifier
        self.appleURL = appleURL
        self.songLinkURL = songLinkURL
        self.title = title
        self.artist = artist
        self.album = album
        self.index = index
    }
    
    
    public let identifier: UInt64
    public let appleURL: String
    public let songLinkURL: String
    public let title: String
    public let artist: String
    public let album: String
    public let index: Int
    
}
