//
//  SongLinkProvider.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//
import Foundation

final class SongLinkProvider: NSObject {
    
    private lazy var service: MusicAssetManager = {
        return MusicAssetManager.shared
    }()
    
    typealias SearchBlock = (_ songLinkReadyItem: SongLinkReadyItem?) -> Void
    typealias Result = (_ songLinks: [SongLinkViewData]) -> Void
    
    typealias Content = (_ cache: [SongLinkViewData], _ remainingSongs: [SongLink]) -> Void
    
    override init() {
        super.init()
    }
    
    func search(in songs: [SongLink]) {
        downloadSongLinks(songs: songs)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = self.checkForAvailableSongs(songs: playlist.items)
                let cache = data.cache
                let remainingSongs = data.downloads
                DispatchQueue.main.async {
                    content(cache, remainingSongs)
            }
        }
    }
    
    // MARK: - Private
    
    private func downloadSongLinks(songs: [SongLink]) {
        
        for song in songs {
            self.search(song: song, searchBlock: { [unowned self] item in
                if let url = item?.url, let originalUrl = item?.originalUrl {
                    let songLink = SongLink(id: song.id,
                                            artist: song.artist,
                                            title: song.title,
                                            album: song.album,
                                            url: url,
                                            originalUrl: originalUrl,
                                            index: song.index,
                                            notFound: song.notFound,
                                            playcount: song.playcount,
                                            downloaded: true,
                                            playlistHash: song.playlistHash,
                                            artwork: Data())
                    self.addToDatabase(song: songLink)
                } else {
                    let error = "Could not find the music track matching these criteria."
                    let songLink = SongLink(id: song.id,
                                            artist: song.artist,
                                            title: song.title,
                                            album: song.album,
                                            url: error,
                                            originalUrl: error,
                                            index: song.index,
                                            notFound: true,
                                            playcount: song.playcount,
                                            downloaded: true,
                                            playlistHash: song.playlistHash,
                                            artwork: nil)
                    self.addToDatabase(song: songLink)
                }
            })
        }
    }
    
    private func search(song: SongLink, searchBlock: @escaping SearchBlock) {
        let escapedString = "\(song.title)+\(song.artist)"
        service.call(path: MusicAssetManager.Path.search(term: escapedString), callback: { json, _ in
            if let contents: [[String: Any]] = json?["results"] as? [[String: Any]] {
                let content = contents.first
                let trackViewUrl = content?["trackViewUrl"] as? String ?? ""
                if trackViewUrl.count > 1 {
                    let newTrack: String = "https://song.link/\(trackViewUrl)&app=music"
                    print(newTrack)
                    let item = SongLinkReadyItem(url: newTrack, originalUrl: trackViewUrl)
                    searchBlock(item)
                } else {
                    searchBlock(nil)
                }
            } else {
                searchBlock(nil)
            }
        })
    }
    
    private func addToDatabase(song: SongLink) {
        let songRepo = SongRepository()
        songRepo.add(element: song)
    }
    
    private func checkForAvailableSongs(songs: [SongLink]) -> (cache: [SongLinkViewData], downloads: [SongLink] ) {
        let predicates = songs.map { NSPredicate(format: "itemId = %@ AND downloaded = true",
                                                $0.itemId,
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
    let id: String
    let artist: String
    let title: String
    let album: String
    let url: String
    let originalUrl: String
    let index: Int
    let notFound: Bool
    let playcount: Int
    let downloaded: Bool
    let playlistHash: String
    let artwork: Data?
    
    init(artist: String, album: String, title: String) {
        self.id = ""
        self.artist = artist
        self.title = title
        self.album = album
        self.url = ""
        self.originalUrl = ""
        self.index = -1
        self.notFound = false
        self.playcount = 0
        self.downloaded = false
        self.playlistHash = ""
        self.artwork = nil
    }
    
    init(id: String,
         artist: String,
         title: String,
         album: String,
         url: String,
         originalUrl: String,
         index: Int,
         notFound: Bool,
         playcount: Int,
         downloaded: Bool,
         playlistHash: String,
         artwork: Data?) {
        self.id = id
        self.artist = artist
        self.title = title
        self.album = album
        self.url = url
        self.originalUrl = originalUrl
        self.index = index
        self.notFound = notFound
        self.playcount = playcount
        self.downloaded = downloaded
        self.playlistHash = playlistHash
        self.artwork = artwork
    }
    
    var itemId: String {
        return "\(self.album) \(self.artist) \(self.title)"
    }
}

extension SongLink: Equatable {
    static func == (lhs: SongLink, rhs: SongLink) -> Bool {
        return (lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}
