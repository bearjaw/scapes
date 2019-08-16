//
//  Repository.swift
//  Scapes
//
//  Created by Max Baumbach on 09/01/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import UIKit

protocol Repository {
    
    typealias ModelsChange = (NSDiffableDataSourceSnapshot<SectionType, RepositoryType>)
    
    associatedtype RepositoryType: Hashable
    associatedtype SectionType: Hashable
    
    func all(matching predicate: NSPredicate?) -> [RepositoryType]
    
    func element(for identifier: String) -> RepositoryType?
    
    func add(element: RepositoryType)
    
    func update(element: RepositoryType)
    
    func update(element identifier: String, value: Any?, for keyPath: String)
    
    func delete(element: RepositoryType)
    
    func search(predicate: NSPredicate) -> RepositoryType?
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([RepositoryType]) -> Void,
                   onChange: @escaping (ModelsChange) -> Void)
    
    func subscribe(entity: RepositoryType, onChange: @escaping (RepositoryType) -> Void)
}
