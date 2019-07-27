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
    
    func parse(collections: [MPMediaItemCollection], includingSongs: Bool) -> [CorePlaylist] {
        self.cache = collections
        var result: [CorePlaylist] = []
        for collection in collections {
            let name = (collection.value(forProperty: MPMediaPlaylistPropertyName) as? String)
            let count = collection.count
            var playlist = CorePlaylist(name: name, itemCount: count)
            if includingSongs {
                playlist.items = parse(songs: collection.items)
            }
            result.append(playlist)
        }
        return result
    }
    
    func parse(songs: [MPMediaItem]) -> [CorePlaylistItem] {
        var result: [CorePlaylistItem] = []
        for song in songs {
            
            let title = song.title
            let artist = song.artist
            let album = song.albumTitle
            let playCount = song.playCount
//            let artwork: MPMediaItemArtwork = song.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            //                let data = Data( artwork.image(at: CGSize(width: 200, height: 200)))
            let item = CorePlaylistItem(title: title ?? "Unknown", album: album, artist: artist ?? "Unknown")
            item.playCount = playCount
            result.append(item)
        }
        return result
    }
}
