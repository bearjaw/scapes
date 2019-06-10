//
//  PlaylistDetailViewProtocol.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

protocol PlaylistDetailViewModelProtocol {}

final class PlaylistDetailViewModel {
    
    private var playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
}

extension PlaylistDetailViewModel: PlaylistDetailViewModelProtocol {}
