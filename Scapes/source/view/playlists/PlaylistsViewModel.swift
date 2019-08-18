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

extension PlaylistsViewModel: ViewModel {
    
    var plugins: [Plugin] {
        get {
            return _plugins
        }
        set {
            _plugins = newValue
        }
    }
    
}

final class PlaylistsViewModel {
    
    private var playlists: [Playlist] = []
    private var _plugins: [Plugin] = []
    private var onInitial: InitialData?
    private var onChange: Changes?
    private var queue = DispatchQueue(label: "com.scapes.playlists.viewmodel", qos: .background)
    private lazy var songRepo: SongRepository = { SongRepository() }()
    
    init(plugins: [Plugin]) {
        _plugins = plugins
    }
    
    private func fetchPlaylists() {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let plugin = self._plugins.first(where: { $0.type == ScapesPluginType.fetchPlaylist.rawValue }) as? FetchPlaylistsPlugin else {
                return
            }
            
            plugin.fetchPlaylists { playlists in
                self.playlists = playlists
                guard let onInitial = self.onInitial else { return }
                onInitial()
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
