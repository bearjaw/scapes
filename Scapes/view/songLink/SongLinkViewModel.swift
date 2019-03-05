//
//  SongLinkViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 04/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

protocol SongLinkViewModelProtocol {
    typealias Indecies = (deletions: [Int], insertions: [Int], modifications: [Int])
    var data: [SongLinkViewData] { get }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void)
    
}

final class SongLinkViewModel: SongLinkViewModelProtocol {
    
    var data: [SongLinkViewData] {
        return items
    }
    private var playlist: Playlist?
    private var remainingSongs: [Song] = []
    private let repo = SongRepository()
    private var token: RepoToken?
    private var items: [SongLinkViewData] = []
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void) {
        token = repo.subscribe(onInitial: { [unowned self] newValue in
            self.items = self.convert(newValue)
            if self.items.isEmpty { onEmpty() }
        }, onChange: { [unowned self] newValue, indecies  in
            self.items = self.convert(newValue)
            if self.items.isEmpty { onEmpty() }
            onChange(indecies)
        })
    }
    
    func convert(_ value: [SongLink]) -> [SongLinkViewData] {
        return value.map({ SongLinkViewData(url: $0.url,
                                                     success: true,
                                                     title: $0.title,
                                                     artist: $0.artist,
                                                     album: $0.album,
                                                     index: $0.index)})
    }
    
    func updatePlaylist(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    func fetchRemainingSongsIfNeeded() {
        guard let playlist = playlist else { return }
        service.provideCachedSongs(for: playlist, content: { [weak self] cache, remainingSongs in
            guard let self = self else { return }
            self.items.append(contentsOf: cache)
            self.remainingSongs = remainingSongs
            self.downloadLinksIfNeeded(songs: remainingSongs)
        })
    }
    
    private func downloadLinksIfNeeded(songs: [Song]) {
        guard songs.isNonEmpty else { return }
        service.search(in: songs) { _ in
            // TODO: remove collection
        }
    }
    
}
