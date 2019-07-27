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
            let artwork = collection.representativeItem?.artwork?.image(at: CGSize(width: 100, height: 100))?.pngData()
            var playlist = CorePlaylist(name: name, itemCount: count, localPlaylistIdentifier: collection.persistentID)
            playlist.artwork = artwork
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
        for song in songs {
            let title = song.title
            let artist = song.artist
            let album = song.albumTitle
            let playCount = song.playCount
            let identifier = song.persistentID
            let item = CorePlaylistItem(title: title ?? "Unknown",
                                        album: album,
                                        artist: artist ?? "Unknown",
                                        localPlaylistIdentifier: identifier)
            if let artwork = song.artwork {
                let data = artwork.image(at: CGSize(width: 100, height: 100))?.pngData()
                item.artwork = data
            }
            item.playCount = playCount
            result.append(item)
        }
        return result
    }
}
