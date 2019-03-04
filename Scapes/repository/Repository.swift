//
//  Repository.swift
//  Scapes
//
//  Created by Max Baumbach on 09/01/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

struct SongLinkDatabaseViewData {
    let artist: String
    let song: String
    let album: String
    let url: String
    let originalUrl: String
    let index: Int
}

extension SongLinkDatabaseViewData: Equatable {
    static func == (lhs: SongLinkDatabaseViewData, rhs: SongLinkDatabaseViewData) -> Bool {
        return (lhs.song == rhs.song && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}

protocol Repository {
    
    associatedtype RepositoryType
    
    func getAll() -> [RepositoryType]
    
    func get(identifier: String) -> RepositoryType?
    
    func add(element: RepositoryType) -> Bool
    
    func update(element: RepositoryType) -> Bool
    
    func delete(element: RepositoryType) -> Bool
    
    func search(predicate: NSPredicate) -> RepositoryType?
}
