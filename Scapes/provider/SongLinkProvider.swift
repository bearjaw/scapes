//
//  SongLinkProvider.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//
import Foundation
import PlaylistKit
import SongLinkKit

final class SongLinkProvider: NSObject {
    
    typealias SearchBlock = (_ songLinkReadyItem: SongLinkReadyItem?) -> Void
    typealias Result = (_ songLinks: [SongLinkViewData]) -> Void
    
    typealias Content = (_ cache: [SongLinkViewData], _ remainingSongs: [SongLink]) -> Void
    
    private lazy var service: SongLinkKit = { SongLinkKit() }()
    
    override init() {
        super.init()
    }
    
    func search(in songs: [SongLink]) {
        downloadSongLinks(songs: songs)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        let queue = DispatchQueue(label: "com.scapes.fetch.songlinks.remote", qos: .userInitiated, attributes: .concurrent, target: .global(qos: .userInteractive))
        queue.async {
            PlaylistKit.fetchSongs(forPlaylist: playlist.identifier) { result in
                switch result {
                case .success(let songs):
                    let songLinks = songs.map { SongLink(artist: $0.artist, album: $0.album, title: $0.title, identifier: $0.localPlaylistIdentifier) }
                    let data = self.checkForAvailableSongs(songs: songLinks)
                    let cache = data.cache
                    let remainingSongs = data.downloads
                    DispatchQueue.main.async {
                        content(cache, remainingSongs)
                    }
                case .failure(let error):
                    dump(error)
                }
                
            }
        }
    }
    
    // MARK: - Private
    
    private func downloadSongLinks(songs: [SongLink]) {
        let requests = songs.map { CoreRequest(identifier: $0.identifier, title: $0.title, artist: $0.artist, album: $0.album, index: $0.index) }
        service.fetchSongs(requests, update: { song in
            let link = SongLink(identifier: song.identifier,
                                artist: song.artist,
                                title: song.title,
                                album: song.album,
                                url: song.songLinkURL,
                                originalUrl: song.appleURL,
                                index: song.index,
                                notFound: false,
                                playcount: 0,
                                downloaded: true,
                                artwork: nil)
            self.addToDatabase(song: link)
        }, completion: { _ in
            
        })
    }
    
    private func addToDatabase(song: SongLink) {
        let songRepo = SongRepository()
        songRepo.add(element: song)
    }
    
    private func checkForAvailableSongs(songs: [SongLink]) -> (cache: [SongLinkViewData], downloads: [SongLink] ) {
        let predicates = songs.map { NSPredicate(format: "identifier = %@ AND downloaded = true",
                                                 "\($0.identifier)",
                                                 true) }
        let compundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let songRepo = SongRepository()
        let results = songRepo.all(matching: compundPredicate)
        let cache = results.map { SongLinkViewData(url: $0.url,
                                                   success: true,
                                                   title: $0.title,
                                                   artist: $0.artist,
                                                   album: $0.album,
                                                   index: $0.index) }
        let songsSet: Set<SongLink> = Set(songs)
        let songsToDownload: Set<SongLink> = songsSet.subtracting(Set(results))
        
        return (cache, Array(songsToDownload))
    }
}

struct SongLinkReadyItem {
    let url: String
    let originalUrl: String
}

struct SongLinkViewData: Equatable {
    let url: String
    let success: Bool
    let title: String
    let artist: String
    let album: String
    let index: Int
}

struct SongLink: Hashable {
    let identifier: UInt64
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
    
    init(artist: String, album: String, title: String, identifier: UInt64) {
        self.identifier = identifier
        self.artist = artist
        self.title = title
        self.album = album
        self.url = ""
        self.originalUrl = ""
        self.index = -1
        self.notFound = false
        self.playcount = 0
        self.downloaded = false
        self.artwork = nil
    }
    
    init(identifier: UInt64,
         artist: String,
         title: String,
         album: String,
         url: String,
         originalUrl: String,
         index: Int,
         notFound: Bool,
         playcount: Int,
         downloaded: Bool,
         artwork: Data?) {
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

extension SongLink: Equatable {
    static func == (lhs: SongLink, rhs: SongLink) -> Bool {
        return (lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}
