//
//  PlaylistViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 08/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import PlaylistKit
import os

protocol PlaylistsViewModelProtocol {
    
    typealias InitialData = () -> Void
    typealias Changes = ([IndexPath], [IndexPath], [IndexPath]) -> Void
    
    var count: Int { get }
    
    func subscribe(to initital: @escaping InitialData, onChange: @escaping Changes)
    
    func item(at indexPath: IndexPath) -> Playlist
}

final class PlaylistsViewModel {
    
    private var playlists: [Playlist] = []
    private var onInitial: InitialData?
    private var onChange: Changes?
    private var queue = DispatchQueue(label: "com.scapes.playlists.viewmodel", qos: .background)
    private lazy var songRepo: SongRepository = { SongRepository() }()
    
    private func fetchPlaylists() {
        queue.async {
            PlaylistKit.fetchPlaylist(source: .local) { [weak self] result in
                switch result {
                case .success(let items):
                    guard let self = self, let onInitial = self.onInitial else { return }
                    self.playlists = items.map { item in
                        let artwork = PlaylistKit.fetchArtwork(forType: .playlist(identifier: item.localPlaylistIdentifier))
                        let playlist = Playlist(name: item.name, count: item.itemCount, identifier: item.localPlaylistIdentifier, artwork: artwork)
                        return playlist
                    }
                    DispatchQueue.main.async {
                        onInitial()
                    }
                case .failure(let error):
                    os_log("%@", error.localizedDescription)
                }
            }
        }
    }
    
}

extension PlaylistsViewModel: PlaylistsViewModelProtocol {
    
    var count: Int {
        return self.playlists.count
    }
    
    func subscribe(to initital: @escaping InitialData, onChange: @escaping Changes) {
        self.onInitial = initital
        self.onChange = onChange
        fetchPlaylists()
    }
    
    func item(at indexPath: IndexPath) -> Playlist {
        return playlists[indexPath.row]
    }
    
}
