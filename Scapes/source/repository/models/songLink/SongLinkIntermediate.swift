//
//  SongLinkIntermediate.swift
//  Scapes
//
//  Created by Max Baumbach on 13/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

struct SongLinkIntermediate: Hashable {
    
    let localPlaylistItemId: UInt64
    let identifier: UUID
    let artist: String
    let title: String
    let album: String
    let url: String
    let originalUrl: String
    let index: Int
    let notFound: Bool
    let playcount: Int
    let downloaded: Bool
    let artwork: Data?
    
    internal init(localPlaylistItemId: UInt64, identifier: UUID, artist: String, title: String, album: String, url: String, originalUrl: String, index: Int, notFound: Bool, playcount: Int, downloaded: Bool, artwork: Data?) {
        self.localPlaylistItemId = localPlaylistItemId
        self.identifier = identifier
        self.artist = artist
        self.title = title
        self.album = album
        self.url = url
        self.originalUrl = originalUrl
        self.index = index
        self.notFound = notFound
        self.playcount = playcount
        self.downloaded = downloaded
        self.artwork = artwork
    }
    

}
extension SongLinkIntermediate: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}
