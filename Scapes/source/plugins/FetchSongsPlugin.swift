//
//  FetchSongsPlugin.swift
//  Scapes
//
//  Created by Max Baumbach on 18/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import Foundation
import PlaylistKit
import os

final class FetchSongsPlugin {
    
    func fetchSongs(forPlaylist playlist: Playlist, onCompletion: @escaping ([SongLinkIntermediate]) -> Void) {
        PlaylistKit.fetchSongs(forPlaylist: playlist.identifier) { result in
            switch result {
            case let .success(items):
                let songs = items.map { $0.intermediate }
                DispatchQueue.main.async {
                    onCompletion(songs)
                }
            case let .failure(error):
                os_log("Error occured: %@", error.localizedDescription)
            }
            
        }
    }
}

extension FetchSongsPlugin: Plugin {
    
    var type: Int { ScapesPluginType.fetchSongs.rawValue }
    
}
