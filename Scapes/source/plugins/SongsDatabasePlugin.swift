//
//  SongsDatabasePlugin.swift
//  Scapes
//
//  Created by Max Baumbach on 18/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit
import PlaylistKit

typealias IntermediateSnapshot = NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>

final class SongsDatabasePlugin {
    
    private lazy var repo: SongRepository = { SongRepository() }()
    
    private var observers: [(IntermediateSnapshot) -> Void] = []
    
    func addSongsToDatabase(_ songs: [CorePlaylistItem], filter: NSPredicate, onCompletion: @escaping () -> Void) {
        repo.applyGlobalFilter(filter)
        repo.add(elements: songs.map({ $0.intermediate }))
        DispatchQueue.main.async {
            onCompletion()
        }
    }
    
    func addSongsToDatabase(_ songs: [SongLinkIntermediate], filter: NSPredicate, onCompletion: @escaping () -> Void) {
        repo.applyGlobalFilter(filter)
        repo.add(elements: songs)
        DispatchQueue.main.async {
            onCompletion()
        }
    }
    
    func observeSongs(filter: NSPredicate, onInitial: @escaping ([SongLinkIntermediate]) -> Void, onUpdate: @escaping (IntermediateSnapshot) -> Void) {
        observers.append(onUpdate)
        repo.subscribe(filter: filter, onInitial: { result in
            DispatchQueue.main.async {
                onInitial(result)
            }
            }, onChange: { [weak self] snapshot in
                guard let self = self else { return }
                self.trigger(snapshot: snapshot)
        })
    }
    
    func addSong(_ song: SongLinkIntermediate) {
        repo.add(element: song)
    }
    
    func all(matching predicate: NSPredicate) -> [SongLinkIntermediate] {
        return repo.all(matching: predicate)
    }
    
    // MARK: - Private
    
    private func trigger(snapshot: IntermediateSnapshot) {
        observers.forEach { $0(snapshot) }
    }
    
}

extension SongsDatabasePlugin: Plugin {
    
    var type: Int { ScapesPluginType.addToDatabase.rawValue }
    
}
