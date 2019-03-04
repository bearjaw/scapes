//
//  Repository.swift
//  Scapes
//
//  Created by Max Baumbach on 09/01/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

extension SongLink: Equatable {
    static func == (lhs: SongLink, rhs: SongLink) -> Bool {
        return (lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}

protocol Repository {
    
    typealias Indecies = (deletions: [Int], insertions: [Int], modifications: [Int])
    
    associatedtype RepositoryType
    associatedtype Token
    
    func getAll() -> [RepositoryType]
    
    func get(identifier: String) -> RepositoryType?
    
    func add(element: RepositoryType) -> Bool
    
    func update(element: RepositoryType) -> Bool
    
    func delete(element: RepositoryType) -> Bool
    
    func search(predicate: NSPredicate) -> RepositoryType?
    
    func subscribe(onInitial: @escaping ([RepositoryType]) -> Void,
                   onChange: @escaping ([RepositoryType], Indecies) -> Void) -> Token?
    
    func subscribe(entity: RepositoryType, onChange: @escaping (RepositoryType) -> Void) -> Token?
}
