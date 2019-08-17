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
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>
    
    var title: String { get }
    
    var data: [SongLinkIntermediate] { get set }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Snapshot) -> Void, onEmpty: @escaping () -> Void)
    
    func subscribe(onCompleted: @escaping () -> Void)
}

final class PlaylistContainerViewModel {
    
    private var _playlist: Playlist
    private var songs: [CorePlaylistItem] = []
    private var onCompleted: (() -> Void)?
    private var onChange: ((Snapshot) -> Void)?
    private var onInitial: (() -> Void)?
    private var onEmpty: (() -> Void)?
    private var queue = DispatchQueue(label: "com.scapes.playlist.detail.viewmodel", qos: .background)
    
    private lazy var repo: SongRepository = {
        let repo = SongRepository()
        return repo
    }()
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    var data: [SongLinkIntermediate] = []
    
    init(playlist: Playlist) {
        _playlist = playlist
    }
    
    private func fetchSongs() {
        queue.async { [weak self] in
            guard let self = self else { return }
            PlaylistKit.fetchSongs(forPlaylist: self.playlist.identifier) { result in
                switch result {
                case .success(let items):
                    self.songs = items
                    self.data = items.map { $0.intermediate }
                    DispatchQueue.main.async {
                        self.updateOnInitial()
                    }
                    self.observeChanges()
                case .failure(let error):
                    os_log("%@", error.localizedDescription)
                }
            }
        }
    }
    
    private func observeChanges() {
        let filter = self.filter()
        repo.subscribe(filter: filter, onInitial: { [weak self] result in
            guard let self = self else { return }
            self.data = result
            DispatchQueue.main.async {
                self.updateOnInitial()
                self.updateIsEmpty(result.isEmpty)
                self.allSongsDownloaded(songs: result)
            }
            }, onChange: { [weak self] snapshot in
                guard let self = self else { return }
                self.updateOnChange(snapshot)
        })
    }
    
    private func updateIsEmpty(_ isEmpty: Bool) {
        guard isEmpty, let onEmpty = onEmpty else { return }
        onEmpty()
    }
    
    private func updateOnInitial() {
        guard let onInitial = onInitial else { return }
        onInitial()
    }
    
    private func updateOnChange(_ snapshot: NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>) {
        guard let onChange = onChange else { return }
        onChange(snapshot)
    }
    
    private func filter() -> NSCompoundPredicate? {
        guard self.songs.isNonEmpty else { return  nil }
        let predicates = self.songs.map({ NSPredicate(format:"localPlaylistIdentifier == %@",
                                                      "\($0.localPlaylistIdentifier)") })
        predicates.forEach { print($0.predicateFormat) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    private func allSongsDownloaded(songs: [SongLinkIntermediate]) {
        let completed = songs.filter { $0.downloaded == false }.isEmpty
        if completed && playlist.count == songs.count, let onCompleted = self.onCompleted {
            self.data.sort { $0.index < $1.index }
            onCompleted()
        }
    }
    
    private func downloadLinksIfNeeded(songs: [SongLinkIntermediate]) {
        guard songs.isNonEmpty else { return }
        service.search(in: songs)
    }
}

extension PlaylistContainerViewModel: PlaylistContainerViewModelProtocol {
    
    var playlist: Playlist {
        return _playlist
    }
    
    var title: String {
        return self.playlist.name
    }
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Snapshot) -> Void, onEmpty: @escaping () -> Void) {
        self.onChange = onChange
        self.onInitial = onInitial
        self.onEmpty = onEmpty
        fetchSongs()
    }
    
    func fetchRemainingSongsIfNeeded() {
        service.provideCachedSongs(for: playlist, content: { [weak self] cache, remainingSongs in
            guard let self = self else { return }
            self.data = cache
            self.downloadLinksIfNeeded(songs: remainingSongs)
        })
    }
    
    func subscribe(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
}
