//
//  PlaylistProvider.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit
import MediaPlayer

final class PlaylistProvider: NSObject {

    static func fetchPlaylist() -> [Playlist] {
        
        let myPlaylistQuery = MPMediaQuery.playlists()
        guard let playlists = myPlaylistQuery.collections else { return [] }
        var mPlaylists: [Playlist] = []
        for playlist in playlists {
            let plTitle = playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "Untitled Playlist"
            let songs = fetchSongs(for: playlist)
            let mPlaylist = Playlist(name: plTitle, count: "\(songs.count)", items: songs)
            mPlaylists.append(mPlaylist)
        }
        return mPlaylists
    }
    
    static func fetchSongs(for playlist: MPMediaItemCollection) -> [SongLink] {
        if playlist.items.isEmpty { return [] }
        var index = 0
        var songs: [SongLink] = []        
        for song in playlist.items {
            if let title: String = song.value(forProperty: MPMediaItemPropertyTitle) as? String,
                let artist: String = song.value(forProperty: MPMediaItemPropertyArtist) as? String,
                let album: String = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String,
                let playcount: NSNumber = song.value(forProperty: MPMediaItemPropertyPlayCount) as? NSNumber {
                let songLink = SongLink(id: UUID().uuidString,
                                        artist: artist,
                                        title: title,
                                        album: album,
                                        url: "",
                                        originalUrl: "",
                                        index: index,
                                        notFound: false,
                                        playcount: playcount.intValue,
                                        downloaded: false,
                                        playlistHash: String(playlist.persistentID))
                songs.append(songLink)
            }
            index += 1
        }
        return songs
    }
}

struct Playlist: Hashable {
    let name: String
    let count: String
    let items: [SongLink]
    
}
