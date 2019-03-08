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
    
    var title: String { get }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void)
    
    func subscribe(onCompleted: @escaping () -> Void)
}

final class SongLinkViewModel: SongLinkViewModelProtocol {
    
    var data: [SongLinkViewData] {
        return items
    }
    
    var title: String {
        guard let playlist = playlist else { return "Playlist" }
        return playlist.name
    }
    
    private var playlist: Playlist?
    private var remainingSongs: [Song] = []
    private let repo = SongRepository()
    private var token: RepoToken?
    private var items: [SongLinkViewData] = []
    private var onCompleted: (() -> Void)?
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void) {
        let filter = self.filter()
        
        token = repo.subscribe(filter: filter, onInitial: { [unowned self] newValue in
            self.items = self.convert(newValue)
            if newValue.isEmpty { onEmpty() }
            self.checkIfCompleted()
            onInitial()
        }, onChange: { [unowned self] newValue, indecies  in
            self.items = self.convert(newValue)
            if newValue.isEmpty { onEmpty() }
            self.checkIfCompleted()
            onChange(indecies)
        })
    }
    
    func filter() -> NSCompoundPredicate? {
        guard let playlist = playlist else { return nil }
        let predicates = playlist.items.map({ NSPredicate(format: "artist == %@ AND album == %@ AND title == %@",
                                               $0.artist,
                                               $0.albumTitle,
                                               $0.title) })
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    func subscribe(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
    
    private func convert(_ value: [SongLink]) -> [SongLinkViewData] {
        if value.isEmpty {
            return []
//            return playlist.items.map({ convert(SongLink(artist: $0.artist, album: $0.albumTitle, title: $0.title ))})
        } else {
            return value.map({ convert($0) })
        }
        
    }
    
    private func convert(_ value: SongLink) -> SongLinkViewData {
        return SongLinkViewData(url: value.url,
                         success: !value.notFound,
                         title: value.title,
                         artist: value.artist,
                         album: value.album,
                         index: value.index)
    }
    
    private func checkIfCompleted() {
        if self.items.count == self.playlist!.items.count,
            let onCompleted = onCompleted,
            self.items.filter({ $0.url.isEmpty}).isEmpty {
            onCompleted()
        }
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
        service.search(in: songs)
    }
    
}
