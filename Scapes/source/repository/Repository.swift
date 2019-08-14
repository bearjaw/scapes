//
//  Repository.swift
//  Scapes
//
//  Created by Max Baumbach on 09/01/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

protocol Repository {
    
    typealias ModelsChange = ([RepositoryType], [IndexPath], [IndexPath], [IndexPath])
    
    associatedtype RepositoryType
    associatedtype Token
    
    func all(matching predicate: NSPredicate?) -> [RepositoryType]
    
    func element(for identifier: String) -> RepositoryType?
    
    func add(element: RepositoryType)
    
    func update(element: RepositoryType)
    
    func update(element identifier: String, value: Any?, for keyPath: String)
    
    func delete(element: RepositoryType)
    
    func search(predicate: NSPredicate) -> RepositoryType?
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([RepositoryType]) -> Void,
                   onChange: @escaping (ModelsChange) -> Void) -> Token?
    
    func subscribe(entity: RepositoryType, onChange: @escaping (RepositoryType) -> Void) -> Token?
}
