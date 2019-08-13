///
///  SongLinkRepository.swift
///  Scapes
///
///  Created by Max Baumbach on 04/03/2019.
///  Copyright © 2019 Max Baumbach. All rights reserved.
///

import Foundation
import CoreData

final class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    
    private var persistentContainer: NSPersistentContainer
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Scapes")
        managedObjectContext = persistentContainer.newBackgroundContext()
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            
            completionClosure()
        }
    }
}


final class SongRepository: NSObject, Repository {
    
    typealias RepositoryType = SongLink
    
    typealias Token = String
    
    private var modelsIndexUpdate: ((ModelsChange) -> Void)?
    private var modelUpdate: ((SongLink) -> Void)?
    private var modelsUpdate: (([SongLink]) -> Void)?
    
    
    private lazy var dataController: DataController = {
        let controller = DataController {}
        return controller
    }()
    
    private lazy var resultsController: NSFetchedResultsController<SongLink> = {
        let request = NSFetchRequest<SongLink>(entityName: "SongLink")
        
        let moc = dataController.managedObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func all(matching predicate: NSPredicate?) -> [SongLink] {
        return []
    }
    
    func element(for identifier: String) -> SongLink? {
        return nil
    }
    
    func add(element: SongLink) {
        resultsController.managedObjectContext.insert(element)
        save()
    }
    
    func update(element: SongLink) {
        save()
    }
    
    func update(element identifier: String, value: Any?, for keyPath: String) {
        
    }
    
    func delete(element: SongLink) {
        resultsController.managedObjectContext.delete(element)
        save()
    }
    
    func search(predicate: NSPredicate) -> SongLink? {
        return nil
    }
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([SongLink]) -> Void, onChange: @escaping (ModelsChange) -> Void) -> String? {
        self.modelsIndexUpdate = onChange
        self.modelsUpdate = onInitial
        resultsController.fetchRequest.predicate = filter
        do {
            try resultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        return nil
    }
    
    func subscribe(entity: SongLink, onChange: @escaping (SongLink) -> Void) -> String? {
        return nil
    }
    
}

extension SongRepository: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        guard let onChange = self.modelsUpdate, let objects = resultsController.fetchedObjects else { return }
        onChange(objects)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            onChange((objects, [indexPath], [], []))
        case .insert:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            onChange((objects, [], [indexPath], []))
        case .update:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            onChange((objects, [], [], [indexPath]))
        case .move:
            break
        @unknown default:
            break
        }
    }
}

extension SongRepository {
    private func save() {
        guard  resultsController.managedObjectContext.hasChanges else { return }
        do {
            try resultsController.managedObjectContext.save()
        } catch {
            fatalError("Error: Could not save managed object context")
        }
    }
}
