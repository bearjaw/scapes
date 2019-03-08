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
    
    var title: String { get }
    
    var data: [SongLinkViewData] { get set }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void)
    
    func subscribe(onCompleted: @escaping () -> Void)
}

final class SongLinkViewModel {
    private var playlist: Playlist
    private var token: RepoToken?
    private var items: [SongLinkViewData] = []
    private var onCompleted: (() -> Void)?
    
    private lazy var repo: SongRepository = {
        let repo = SongRepository()
        return repo
    }()
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    var data: [SongLinkViewData] = []
    
    init(playlist: Playlist) {
        data = []
        self.playlist = playlist
    }
    
    private func filter() -> NSCompoundPredicate? {
        let predicates = playlist.items.map({ NSPredicate(format: "artist == %@ AND album == %@ AND title == %@",
                                               $0.artist,
                                               $0.album,
                                               $0.title) })
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
        return SongLinkViewData(url: value.url,
                         success: value.notFound,
                         title: value.title,
                         artist: value.artist,
                         album: value.album,
                         index: value.index)
    }
    
    private func allSongsDownloaded(songs: [SongLink]) {
        let completed = songs.filter { $0.downloaded == false }.isEmpty
        if completed, let onCompleted = self.onCompleted {
            onCompleted()
        }
    }
    
    private func downloadLinksIfNeeded(songs: [SongLink]) {
        guard songs.isNonEmpty else { return }
        service.search(in: songs)
    }
}

extension SongLinkViewModel: SongLinkViewModelProtocol {
    
    var title: String {
        return playlist.name
    }
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void) {
        let filter = self.filter()
        
        token = repo.subscribe(filter: filter, onInitial: { [unowned self] newValue in
            self.allSongsDownloaded(songs: newValue)
            self.data = self.convert(newValue)
            if newValue.isEmpty { onEmpty() }
            onInitial()
            }, onChange: { [unowned self] newValue, indecies  in
                self.data = self.convert(newValue)
                self.allSongsDownloaded(songs: newValue)
                if newValue.isEmpty { onEmpty() }
                onChange(indecies)
        })
    }
    
    func fetchRemainingSongsIfNeeded() {
        service.provideCachedSongs(for: playlist, content: { [weak self] _, remainingSongs in
            guard let self = self else { return }
            self.downloadLinksIfNeeded(songs: remainingSongs)
        })
    }
    
    func subscribe(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
}
