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
    var playlist: LiveData<Playlist> { get }
    typealias Indicies = (deletions: [Int], insertions: [Int], modifications: [Int])
    
    var title: String { get }
    
    var data: [SongLink] { get set }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indicies) -> Void, onEmpty: @escaping () -> Void)
    
    func subscribe(onCompleted: @escaping () -> Void)
}

final class PlaylistContainerViewModel {
    
    private var _playlist = LiveData<Playlist>()
    private var token: RepoToken?
    private var items: [SongLinkViewData] = []
    private var songs: [CorePlaylistItem] = []
    private var onCompleted: (() -> Void)?
    
    private lazy var repo: SongRepository = {
        let repo = SongRepository()
        return repo
    }()
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    var data: [SongLink] = []
    
    init(playlist: Playlist) {
        self.playlist.value = playlist
        fetchSongs()
    }
    
    private func fetchSongs() {
        PlaylistKit.fetchSongs(forPlaylist: playlist.value!.identifier) { result in
            switch result {
            case .success(let items):
                self.songs = items
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    private func filter() -> NSCompoundPredicate? {
        let predicates = self.songs.map({ NSPredicate(format: "identifier == %@",
                                                      "\($0.localPlaylistIdentifier)") })
        predicates.forEach { print($0.predicateFormat) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    private func convert(_ value: [SongLink]) -> [SongLinkViewData] {
        if value.isEmpty {
            return []
        } else {
            return value.map { convert($0) }
        }
    }
    
    private func convert(_ value: SongLink) -> SongLinkViewData {
        return SongLinkViewData(url: value.url  ?? "",
                                success: value.notFound,
                                title: value.title ?? "",
                                artist: value.artist ?? "",
                                album: value.album ?? "",
                                index: Int(value.index))
    }
    
    private func allSongsDownloaded(songs: [SongLink]) {
        let completed = songs.filter { $0.downloaded == false }.isEmpty
        if completed && playlist.value!.count == songs.count, let onCompleted = self.onCompleted {
            self.data.sort { $0.index < $1.index }
            onCompleted()
        }
    }
    
    private func downloadLinksIfNeeded(songs: [SongLink]) {
        guard songs.isNonEmpty else { return }
        service.search(in: songs)
    }
}

extension PlaylistContainerViewModel: PlaylistContainerViewModelProtocol {
    var playlist: LiveData<Playlist> {
        return _playlist
    }
    
    var title: String {
        return self.playlist.value!.name
    }
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indicies) -> Void, onEmpty: @escaping () -> Void) {
        let filter = self.filter()
//        token = repo.subscribe(filter: filter, onInitial: { [unowned self] newValue in
//            self.data = newValue
//            if newValue.isEmpty { onEmpty() }
//            onInitial()
//            self.allSongsDownloaded(songs: newValue)
//            }, onChange: { [unowned self] newValue, indecies  in
//                self.data = newValue
//                if newValue.isEmpty { onEmpty() }
//                onChange(indecies)
//                self.allSongsDownloaded(songs: newValue)
//        })
    }
    
    func fetchRemainingSongsIfNeeded() {
        service.provideCachedSongs(for: playlist.value!, content: { [weak self] _, remainingSongs in
            guard let self = self else { return }
            self.downloadLinksIfNeeded(songs: remainingSongs)
        })
    }
    
    func subscribe(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
}
