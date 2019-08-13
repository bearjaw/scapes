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
    
    typealias Content = (_ cache: [SongLinkViewData], _ remainingSongs: [CorePlaylistItem]) -> Void
    
    private lazy var service: SongLinkKit = { SongLinkKit() }()
    
    override init() {
        super.init()
    }
    
    func search(in songs: [CorePlaylistItem]) {
        downloadSongLinks(songs: songs)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        let queue = DispatchQueue(label: "com.scapes.fetch.songlinks.remote", qos: .userInitiated, attributes: .concurrent, target: .global(qos: .userInteractive))
        queue.async {
            PlaylistKit.fetchSongs(forPlaylist: playlist.identifier) { result in
                switch result {
                case .success(let songs):
                    let data = self.checkForAvailableSongs(songs: songs)
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
    
    private func downloadSongLinks(songs: [CorePlaylistItem]) {
        let requests = songs.map { CoreRequest(identifier: $0.localPlaylistIdentifier, title: $0.title, artist: $0.artist, album: $0.album, index: $0.index) }
        service.fetchSongs(requests, update: { song in
//            let link = SongLink(identifier: song.identifier,
//                                artist: song.artist,
//                                title: song.title,
//                                album: song.album,
//                                url: song.songLinkURL,
//                                originalUrl: song.appleURL,
//                                index: song.index,
//                                notFound: false,
//                                playcount: 0,
//                                downloaded: true,
//                                artwork: nil)
            
            self.addToDatabase(song: link)
        }, completion: { _ in

        })
    }
    
    private func addToDatabase(song: SongLink) {
        let songRepo = SongRepository()
//        songRepo.add(element: song)
    }
    
    private func checkForAvailableSongs(songs: [CorePlaylistItem]) -> (cache: [SongLinkViewData], downloads: [CorePlaylistItem] ) {
        let predicates = songs.map { NSPredicate(format: "identifier = %@ AND downloaded = true",
                                                 "\($0.identifier)") }
        let compundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let songRepo = SongRepository()
        let results: [SongLink] = songRepo.all(matching: compundPredicate)
        results.forEach { $0.playCount = Int64($0.playCount) }
        songRepo.saveObjects()
        let cache = results.map { SongLinkViewData(identifier: $0.identifier ?? "",
                                                   downloaded: true,
                                                   url: $0.url ?? "",
                                                   success: true,
                                                   title: $0.title ?? "",
                                                   artist: $0.artist ?? "",
                                                   album: $0.album ?? "",
                                                   index: Int($0.index)) }
        let items = songs.compactMap { $0.identifier }
        let cached = results.compactMap { $0.identifier }
        let songsSet = Set(items)
        let songsToDownload: Set<CorePlaylistItem> = songsSet.subtracting(Set(cached))
        return (cache, Array(songsToDownload))
    return ([], [])
    }
}

struct SongLinkReadyItem {
    let url: String
    let originalUrl: String
}

struct SongLinkViewData: Equatable {
    let identifier: String
    let downloaded: Bool
    let url: String
    let success: Bool
    let title: String
    let artist: String
    let album: String
    let index: Int
}
