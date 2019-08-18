//
//  DownloadSongPlugin.swift
//  Scapes
//
//  Created by Max Baumbach on 18/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import Foundation
import SongLinkKit

final class DownloadSongPlugin {
    
    private var database: SongsDatabasePlugin
    
    private lazy var service: SongLinkKit = { SongLinkKit() }()
    
    init(database: SongsDatabasePlugin) {
        self.database = database
    }
    
    func songsToDownload(_ predicate: NSPredicate) -> [SongLinkIntermediate] {
        return database.all(matching: predicate)
    }
    
    func downloadSongs(songs: [SongLinkIntermediate]) {
        let requests = songs.map { CoreRequest(identifier: $0.localPlaylistItemId, title: $0.title, artist: $0.artist, album: $0.album, index: $0.index) }
             service.fetchSongs(requests, update: { song in
                 guard var link = songs.first(where: { $0.localPlaylistItemId == song.identifier }) else { return }
                 link.downloaded = true
                 link.originalUrl = song.appleURL
                 link.url = song.songLinkURL
                 self.database.addSong(link)
             }, completion: { _ in

             })
    }
    
//    private func allSongsDownloaded(songs: [SongLinkIntermediate]) {
//        let completed = songs.filter { $0.downloaded == false }.isEmpty
//        if completed && playlist.count == songs.count, let onCompleted = self.onCompleted {
//            self.data.sort { $0.index < $1.index }
//            onCompleted()
//        }
//    }
//    
//    
//    private func downloadLinksIfNeeded(songs: [SongLinkIntermediate]) {
//        guard songs.isNonEmpty else { return }
//        service.search(in: songs)
//    }
}

extension DownloadSongPlugin: Plugin {
    
    var type: Int { ScapesPluginType.downloadSongs.rawValue }
}
