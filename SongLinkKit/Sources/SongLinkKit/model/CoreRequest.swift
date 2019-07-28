//
//  CoreRequest.swift
//  
//
//  Created by Max Baumbach on 28/07/2019.
//

import Foundation

public struct CoreRequest: Codable, Hashable {
    
    public init(identifier: UInt64, title: String, artist: String, album: String, index: Int) {
        self.identifier = identifier
        self.title = title
        self.artist = artist
        self.album = album
        self.index = index
    }
    
    public let identifier: UInt64
    public let title: String
    public let artist: String
    public let album: String
    public let index: Int
    
    var appleURL: URL {
        
        let compoundURL = URLComponents(scheme: "https",
                                        host: "itunes.apple.com",
                                        path: "/search",
                                        queryItems: self.queryItems)
        guard let url = compoundURL.url else { fatalError("Error") }
        
        return url
    }
    
    private var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "term", value: "\(title)+\(artist)"),
            URLQueryItem(name: "entity", value: "musicTrack")
        ]
    }
    
    var baseURL: URL {
        guard let url = URL(string: "https://itunes.apple.com/") else { fatalError("Can't create base URL!") }
        return url
    }
    
    func generateCoreSongLink(from url: String, trackViewURL: String) -> CoreSongLink {
        CoreSongLink(identifier: identifier, appleURL: trackViewURL, songLinkURL: url, title: title, artist: artist, album: album, index: index)
    }
}
