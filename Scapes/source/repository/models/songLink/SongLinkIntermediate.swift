//
//  SongLinkIntermediate.swift
//  Scapes
//
//  Created by Max Baumbach on 13/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit
import PlaylistKit
import SongLinkKit

struct SongLinkIntermediate: Hashable {
    
    let localPlaylistItemId: UInt64
    let identifier: UUID
    var artist: String
    var title: String
    var album: String
    var url: String
    var originalUrl: String
    var index: Int
    var notFound: Bool
    var playcount: Int
    var downloaded: Bool
    var artwork: Data?
    
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
    
    static func == (lhs: SongLinkIntermediate, rhs: SongLinkIntermediate) -> Bool {
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(artist)
        hasher.combine(album)
    }
    
}

extension SongLinkIntermediate {
    var playlistItem: CorePlaylistItem {
        CorePlaylistItem(title: self.title,
                         album: self.album,
                         artist: self.artist,
                         localPlaylistIdentifier: self.localPlaylistItemId,
                         index: self.index,
                         playCount: self.playcount)
    }
    
    var request: CoreRequest {
        CoreRequest(identifier: self.localPlaylistItemId,
                    title: self.title,
                    artist: self.artist,
                    album: self.album,
                    index: self.index)
    }
}

extension CorePlaylistItem {
    var intermediate: SongLinkIntermediate {
        SongLinkIntermediate(localPlaylistItemId: self.localPlaylistIdentifier,
                             identifier: self.identifier,
                             artist: self.artist,
                             title: self.title,
                             album: self.album,
                             url: "",
                             originalUrl: "",
                             index: Int(self.index),
                             notFound: false,
                             playcount: Int(self.playCount),
                             downloaded: false,
                             artwork: nil)
    }
}

extension SongLink {
    var intermediate: SongLinkIntermediate {
        SongLinkIntermediate(localPlaylistItemId: UInt64(self.localPlaylistIdentifier ?? "")!,
                             identifier: self.identifier ?? UUID(),
                             artist: self.artist ?? "",
                             title: self.title ?? "",
                             album: self.album ?? "",
                             url: self.url ?? "",
                             originalUrl: self.originalURL ?? "",
                             index: Int(self.index),
                             notFound: self.notFound,
                             playcount: Int(self.playCount),
                             downloaded: self.downloaded,
                             artwork: self.artwork)
    }
}
