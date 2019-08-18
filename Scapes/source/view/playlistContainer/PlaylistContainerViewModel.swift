//
//  PlaylistContainerViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import UIKit
import PlaylistKit
import os

protocol PlaylistContainerViewModelProtocol {
    
    var playlist: Playlist { get }
    
    var title: String { get }
    
    var data: [SongLinkIntermediate] { get set }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (IntermediateSnapshot) -> Void, onCompleted: @escaping (Bool) -> Void)
}

final class PlaylistContainerViewModel {
    
    private var _playlist: Playlist
    private var _plugins: [Plugin] = []
    private var onChange: ((IntermediateSnapshot) -> Void)?
    private var onInitial: (() -> Void)?
    private var onCompleted: ((Bool) -> Void)?
    private var queue = DispatchQueue(label: "com.scapes.playlist.detail.viewmodel", qos: .background)
    
    private lazy var repo: SongRepository = { SongRepository() }()
    
    private lazy var service: SongLinkProvider = {
        let provider = SongLinkProvider()
        provider.addToRepository(repository: repo)
        return provider
    }()
    
    var data: [SongLinkIntermediate] = []
    
    init(playlist: Playlist, plugins: [Plugin]) {
        _playlist = playlist
        _plugins = plugins
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let plugin = self.fetchSongs else { return }
            plugin.fetchSongs(forPlaylist: playlist) { songs in
                self.data = songs
                guard let plugin = self.database,
                    let filter = self.filter else { return }
                // Always add or update songs to keept track of properties like playcount
                plugin.addSongsToDatabase(songs, filter: filter) {
                    // Observe & apply any changes
                    self.observerPlaylist()
                }
            }
        }
    }
    
    private func observerPlaylist() {
        guard let plugin = database, let filter = filter else { return }
        plugin.observeSongs(filter: filter, onInitial: { [weak self] songs in
            guard let self = self else { return }
            self.data = songs
            self.queue.async {
                let snapshot = NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>()
                snapshot.appendSections([.items])
                snapshot.appendItems(songs)
                self.updateOnChange(snapshot)
            }
        }, onUpdate: { [weak self] update in
            guard let self = self else { return }
            self.data = update.itemIdentifiers
            self.updateOnChange(update)
        })
    }
    
    private func updateOnInitial() {
        guard let onInitial = onInitial else { return }
        onInitial()
    }
    
    private func updateOnChange(_ snapshot: NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>) {
        guard let onChange = onChange else { return }
        onChange(snapshot)
    }
}

extension PlaylistContainerViewModel: PlaylistContainerViewModelProtocol {
    
    var playlist: Playlist {
        return _playlist
    }
    
    var title: String {
        return self.playlist.name
    }
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (IntermediateSnapshot) -> Void, onCompleted: @escaping (Bool) -> Void) {
        self.onChange = onChange
        self.onInitial = onInitial
        self.onCompleted = onCompleted
    }
    
    func fetchRemainingSongsIfNeeded() {
        guard let filter = self.downloadFilter,
            data.isNonEmpty,
        let plugin = download else { return }
        let songs = plugin.songsToDownload(filter)
        guard songs.isNonEmpty else {
            onCompleted?(true)
            return
        }
        queue.async {
            plugin.downloadSongs(songs: songs)
        }
    }
}

extension PlaylistContainerViewModel {
    var filter: NSPredicate? {
        guard self.data.isNonEmpty else { return  nil }
        let predicates = self.data.map({ NSPredicate(format:"localPlaylistItemIdentifier == %@",
                                                      "\($0.localPlaylistItemId)") })
        predicates.forEach { print($0.predicateFormat) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    var downloadFilter: NSPredicate? {
        guard self.data.isNonEmpty else { return  nil }
        let predicates = self.data.map({ NSPredicate(format:"localPlaylistItemIdentifier == %@ AND downloaded == false",
                                                      "\($0.localPlaylistItemId)") })
        predicates.forEach { print($0.predicateFormat) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}

// MARK: - Convenience Plugin Getters

extension PlaylistContainerViewModel: ViewModel {
    var plugins: [Plugin] {
        get {
            _plugins
        }
        set {
            _plugins = newValue
        }
    }
    
    private var database: SongsDatabasePlugin? {
        guard let plugin = _plugins.first(where: { $0.type == ScapesPluginType.addToDatabase.rawValue }) as? SongsDatabasePlugin else {
            return nil
        }
        return plugin
    }
    
    private var fetchSongs: FetchSongsPlugin? {
        guard let plugin = self._plugins.first(where: { $0.type == ScapesPluginType.fetchSongs.rawValue }) as? FetchSongsPlugin else { return nil }
        return plugin
    }
    
    private var download: DownloadSongPlugin? {
        guard let plugin = self._plugins.first(where: { $0.type == ScapesPluginType.downloadSongs.rawValue }) as? DownloadSongPlugin else { return nil }
        return plugin
    }
}
