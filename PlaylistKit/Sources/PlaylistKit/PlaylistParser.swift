//
//  File.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation
import MediaPlayer

final class PlaylistParser {
    
    private var cache: [MPMediaItemCollection] = []
    
    func parse(collections: [MPMediaItemCollection]) -> [CorePlaylist] {
        self.cache = collections
        var result: [CorePlaylist] = []
        for collection in collections {
            let name = (collection.value(forProperty: MPMediaPlaylistPropertyName) as? String)
            let count = collection.count
            let playlist = CorePlaylist(name: name, itemCount: count, localPlaylistIdentifier: collection.persistentID)
            result.append(playlist)
        }
        return result
    }
    
    func parseSongs(forPlaylist playlist: MPMediaItemCollection) -> [CorePlaylistItem] {
        let songs = parse(songs: playlist.items)
        return songs
    }
    
    // MARK: - MediaItem to CorePlaylistIem mapping
    
    private func parse(songs: [MPMediaItem]) -> [CorePlaylistItem] {
        var result: [CorePlaylistItem] = []
        var index = 0
        #if targetEnvironment(simulator)
        return getMockSongs()
        #endif
        
        for song in songs {
            let title = song.title
            let artist = song.artist
            let album = song.albumTitle
            let playCount = song.playCount
            let identifier = song.persistentID
            let item = CorePlaylistItem(title: title,
                                        album: album,
                                        artist: artist,
                                        localPlaylistIdentifier: identifier,
                                        index: index,
                                        playCount: playCount)
            result.append(item)
            index += 1
        }
        return result
    }
}

extension PlaylistParser {
    private func getMockSongs() -> [CorePlaylistItem] {
        let item0 = CorePlaylistItem(title: "Flip your wig",
                                     album:"Flip your wig",
                                     artist: "Hüsker Dü",
                                     localPlaylistIdentifier: 7719662635198339807,
                                     index: 0,
                                     playCount: 0)
        let item1 = CorePlaylistItem(title: "Makes no Sense at all",
                                     album:"Flip your wig",
                                     artist: "Hüsker Dü",
                                     localPlaylistIdentifier: 7719662635398339807,
                                     index: 0,
                                     playCount: 0)
        let item2 = CorePlaylistItem(title: "Every everything",
                                     album:"Flip your wig",
                                     artist: "Hüsker Dü",
                                     localPlaylistIdentifier: 7719622625398339807,
                                     index: 0,
                                     playCount: 0)
        return [item0, item1, item2]
    }
}
