//
//  PlaylistDetailViewProtocol.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

protocol PlaylistDetailViewModelProtocol {
    func subscribe(onChange: @escaping (Playlist) -> Void)
}

final class PlaylistDetailViewModel {
    
    private var playlist: Playlist
    private var onChange: ((Playlist) -> Void)?
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    private func triggerCallback() {
        guard let onChange = onChange else { return }
        onChange(playlist)
    }
}

extension PlaylistDetailViewModel: PlaylistDetailViewModelProtocol {
    func subscribe(onChange: @escaping (Playlist) -> Void) {
        self.onChange = onChange
        triggerCallback()
    }
}
