//
//  PlaylistDetailViewProtocol.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit
import PlaylistKit

protocol PlaylistDetailViewModelProtocol {
    func subscribe(onChange: @escaping (Playlist) -> Void)
}

final class PlaylistDetailViewModel {
    
    private var playlist: Playlist
    private var onChange: ((Playlist) -> Void)?
    private var queue = DispatchQueue(label: "com.scpaes.playlist.detail.viewmodel", qos: .background)
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
    }
    
    private func triggerCallback() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let artwork = PlaylistKit.fetchArtwork(forType: .playlist(identifier: self.playlist.identifier))
            let playlist = Playlist(name: self.playlist.name, count: self.playlist.count, identifier: self.playlist.identifier, artwork: artwork)
            DispatchQueue.main.async {
                guard let onChange = self.onChange else { return }
                self.playlist = playlist
                onChange(playlist)
            }
        }
    }
}

extension PlaylistDetailViewModel: PlaylistDetailViewModelProtocol {
    func subscribe(onChange: @escaping (Playlist) -> Void) {
        self.onChange = onChange
        triggerCallback()
    }
}
