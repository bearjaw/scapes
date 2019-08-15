//
//  PlaylistContainerViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import ObserverKit
import PlaylistKit

protocol PlaylistContainerViewModelProtocol {
    var playlist: Playlist { get }
    typealias Indicies = (deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath])
    
    var title: String { get }
    
    var data: [SongLinkIntermediate] { get set }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indicies) -> Void, onEmpty: @escaping () -> Void)
    
    func subscribe(onCompleted: @escaping () -> Void)
}

final class PlaylistContainerViewModel {
    
    private var _playlist: Playlist
    private var token: RepoToken?
    private var items: [SongLinkIntermediate] = []
    private var songs: [CorePlaylistItem] = []
    private var onCompleted: (() -> Void)?
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
        fetchSongs()
    }
    
    private func fetchSongs() {
        queue.async { [weak self] in
            guard let self = self else { return }
            PlaylistKit.fetchSongs(forPlaylist: self.playlist.identifier) { result in
                switch result {
                case .success(let items):
                    self.songs = items
                case .failure(let error):
                    dump(error)
                }
            }
            
        }
    }
    
    private func filter() -> NSCompoundPredicate? {
        let predicates = self.songs.map({ NSPredicate(format: "localPlaylistIdentifier == %@",
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
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indicies) -> Void, onEmpty: @escaping () -> Void) {
        let filter = self.filter()
        _ = repo.subscribe(filter: filter, onInitial: { [weak self] result in
            guard let self = self else { return }
            self.data = result
            if result.isEmpty { onEmpty() }
            onInitial()
            self.allSongsDownloaded(songs: result)
            }, onChange: { [weak self] change in
                guard let self = self else { return }
                let (update, deletions, insertions, modifications) = change
                self.data = update
                if update.isEmpty { onEmpty() }
                onChange((deletions, insertions, modifications))
                self.allSongsDownloaded(songs: update)
        })
    }
    
    func fetchRemainingSongsIfNeeded() {
        service.provideCachedSongs(for: playlist, content: { [weak self] cache, remainingSongs in
            guard let self = self else { return }
            self.data = cache
            self.downloadLinksIfNeeded(songs: remainingSongs)
            guard let onCompleted = self.onCompleted else { return }
            onCompleted()
        })
    }
    
    func subscribe(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
}
