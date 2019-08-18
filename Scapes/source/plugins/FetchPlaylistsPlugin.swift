//
//  FetchSongsPlugin.swift
//  Scapes
//
//  Created by Max Baumbach on 18/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import PlaylistKit
import Foundation
import os

protocol Plugin {
    var type: Int { get }
}

final class FetchPlaylistsPlugin {
    
    func fetchPlaylists(onCompletion: @escaping ([Playlist]) -> Void) {
        PlaylistKit.fetchPlaylist(source: .local) { result in
            switch result {
            case let .success(items):
                let playlists: [Playlist] = items.map { item in
                    let artwork = PlaylistKit.fetchArtwork(forType: .playlist(identifier: item.localPlaylistIdentifier))
                    let playlist = Playlist(name: item.name, count: item.itemCount, identifier: item.localPlaylistIdentifier, artwork: artwork)
                    return playlist
                }
                DispatchQueue.main.async {
                    onCompletion(playlists)
                }
            case let .failure(error):
                onCompletion([])
                os_log("%@", error.localizedDescription)
            }
        }
    }
    
}

extension FetchPlaylistsPlugin: Plugin {
    var type: Int { ScapesPluginType.fetchPlaylist.rawValue }
}
