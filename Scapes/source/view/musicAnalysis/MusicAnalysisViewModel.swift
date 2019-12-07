//
//  MusicAnalysisViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 07/12/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

import PlaylistKit
import os

protocol MusicAnalysisViewModelProtocol {
    
    typealias InitialData = () -> Void
    typealias Changes = ([IndexPath], [IndexPath], [IndexPath]) -> Void
    
    var count: Int { get }
    
    func subscribe(to initital: @escaping InitialData, onChange: @escaping Changes)
    
    func item(at indexPath: IndexPath) -> SongLinkIntermediate
}

extension MusicAnalysisViewModel: ViewModel {
    
    var plugins: [Plugin] {
        get {
            return _plugins
        }
        set {
            _plugins = newValue
        }
    }
    
}

final class MusicAnalysisViewModel {
    
    private var songs: [SongLinkIntermediate] = []
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
            let plugin: FetchSongsPlugin = self._plugins.plugin(type: .fetchSongs)
            
            plugin.fetchSongsForCurrentYear { songs in
                self.songs = songs
                guard let onInitial = self.onInitial else { return }
                onInitial()
            }
        }
    }
    
}

extension MusicAnalysisViewModel: MusicAnalysisViewModelProtocol {
    
    var count: Int {
        return self.songs.count
    }
    
    func subscribe(to initital: @escaping InitialData, onChange: @escaping Changes) {
        self.onInitial = initital
        self.onChange = onChange
        fetchPlaylists()
    }
    
    func item(at indexPath: IndexPath) -> SongLinkIntermediate {
        return songs[indexPath.row]
    }
    
}
