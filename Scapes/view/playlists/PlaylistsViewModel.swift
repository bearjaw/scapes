//
//  PlaylistViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 08/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

protocol PlaylistsViewModelProtocol {
    var data: [Playlist] { get }
}

final class PlaylistsViewModel: PlaylistsViewModelProtocol {
    var data: [Playlist] {
        return playlists
    }
    
    private var playlists: [Playlist] = []
    
    init() {
        playlists = PlaylistProvider.fetchPlaylist()
    }
}
