//
//  PlaylistViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 08/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import PlaylistKit

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
    
    private func fetchPlaylists() {
        PlaylistKit.fetchPlaylist(source: .local) { [weak self] result in
            switch result {
            case .success(let items):
                guard let self = self, let onInitial = self.onInitial else { return }
                self.playlists = items.map { Playlist(name: $0.name, count: $0.itemCount, identifier: $0.localPlaylistIdentifier) }
                DispatchQueue.main.async {
                    onInitial()
                }
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    func item(at indexPath: IndexPath) -> Playlist {
        return playlists[indexPath.row]
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
}
