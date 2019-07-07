//
//  PlaylistViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 08/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

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
        PlaylistProvider.fetchPlaylists(onResult: { [unowned self] result in
            switch result {
            case .success(let playlists):
                self.playlists = playlists
                guard let onInitial = self.onInitial else { return }
                onInitial()
            case .failure(let error):
                guard let error = error as? Loggable else { return }
                dump(error.reason)
            }
        })
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
