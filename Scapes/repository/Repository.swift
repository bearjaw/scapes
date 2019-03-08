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
    
    func all(matching predicate: NSPredicate?) -> [RepositoryType]
    
    func get(identifier: String) -> RepositoryType?
    
    func add(element: RepositoryType)
    
    func update(element: RepositoryType)
    
    func delete(element: RepositoryType)
    
    func search(predicate: NSPredicate) -> RepositoryType?
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([RepositoryType]) -> Void,
                   onChange: @escaping ([RepositoryType], Indecies) -> Void) -> Token?
    
    func subscribe(entity: RepositoryType, onChange: @escaping (RepositoryType) -> Void) -> Token?
}
