//
//  PlaylistContainerViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import ObserverKit

protocol PlaylistContainerViewModelProtocol {
    var playlist: LiveData<Playlist> { get }
}

final class PlaylistContainerViewModel {
    
    private var _playlist = LiveData<Playlist>()
    
    init(playlist: Playlist) {
        self.playlist.value = playlist
    }
}

extension PlaylistContainerViewModel: PlaylistContainerViewModelProtocol {
    var playlist: LiveData<Playlist> {
        return _playlist
    }
}
