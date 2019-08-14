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
    
    typealias Result = (_ songLinks: [SongLinkIntermediate]) -> Void
    
    typealias Content = (_ cache: [SongLinkIntermediate], _ remainingSongs: [SongLinkIntermediate]) -> Void
    
    private lazy var service: SongLinkKit = { SongLinkKit() }()
    
    private lazy var songRepo = { SongRepository() }()
    
    func search(in songs: [SongLinkIntermediate]) {
        downloadSongLinks(songs: songs)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        let queue = DispatchQueue(label: "com.scapes.fetch.songlinks.remote", qos: .userInitiated, attributes: .concurrent, target: .global(qos: .userInteractive))
        queue.async {
            PlaylistKit.fetchSongs(forPlaylist: playlist.identifier) { result in
                switch result {
                case .success(let songs):
                    let itermediates = songs.map { $0.intermediate }
                    let data = self.checkForAvailableSongs(songs: itermediates)
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
    
    private func downloadSongLinks(songs: [SongLinkIntermediate]) {
        let requests = songs.map { CoreRequest(identifier: $0.localPlaylistItemId, title: $0.title, artist: $0.artist, album: $0.album, index: $0.index) }
        service.fetchSongs(requests, update: { song in
            guard var link = songs.first(where: { $0.localPlaylistItemId == song.identifier }) else { return }
            link.downloaded = true
            link.originalUrl = song.appleURL
            link.url = song.songLinkURL
            self.songRepo.add(element: link)
        }, completion: { _ in

        })
    }
    
    private func checkForAvailableSongs(songs: [SongLinkIntermediate]) -> (cache: [SongLinkIntermediate], downloads: [SongLinkIntermediate] ) {
        let predicates = songs.map { NSPredicate(format: "localPlaylistIdentifier = %@ AND downloaded = true",
                                                 "\($0.localPlaylistItemId)") }
        let compundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let results: [SongLinkIntermediate] = songRepo.all(matching: compundPredicate)
        let songsSet = Set(songs)
        let cache = Set(results)
        let songsToDownload = songsSet.subtracting(cache)
        return (results, Array(songsToDownload))
    }
}
