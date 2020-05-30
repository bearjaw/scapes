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
        PlaylistKit.fetchSongs(forPlaylist: playlist.identifier) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.handleCompletion(items: items, onCompletion: onCompletion)
            case let .failure(error):
                os_log("Error occured: %@", error.localizedDescription)
            }
            
        }
    }
    
    func fetchSongsForCurrentYear(onCompletion: @escaping ([SongLinkIntermediate]) -> Void) {
        PlaylistKit.fetchSongsHeardInCurrentYear { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(items):
                self.handleCompletion(items: items, onCompletion: onCompletion)
            case let .failure(error):
                os_log("Error occured: %@", error.localizedDescription)
            }
        }
    }
    
    private func handleCompletion(items: [CorePlaylistItem], onCompletion: @escaping ([SongLinkIntermediate]) -> Void) {
        let songs = items.map { $0.intermediate }
        DispatchQueue.main.async {
            onCompletion(songs)
        }
    }
}

extension FetchSongsPlugin: Plugin {
    
    var type: Int { ScapesPluginType.fetchSongs.rawValue }
    
}
