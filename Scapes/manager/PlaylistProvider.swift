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
    
    static func fetchSongs(for playlist: MPMediaItemCollection) -> [Song] {
        precondition(playlist.items.isNonEmpty)
        var index = 0
        var songsViewData: [Song] = []
        for song in playlist.items {
            if let title: String = song.value(forProperty: MPMediaItemPropertyTitle) as? String,
                let artist: String = song.value(forProperty: MPMediaItemPropertyArtist) as? String,
                let albumTitle: String = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String {
                let mSong = Song(artist: artist, title: title, albumTitle: albumTitle, index: index)
                songsViewData.append(mSong)
            }
            index += 1
        }
        return songsViewData
    }
}

struct Playlist {
    let name: String
    let count: String
    let items: [Song]
}

struct Song: Equatable {
    let artist: String
    let title: String
    let albumTitle: String
    let index: Int
}
