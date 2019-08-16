///
///  SongLinkRepository.swift
///  Scapes
///
///  Created by Max Baumbach on 04/03/2019.
///  Copyright © 2019 Max Baumbach. All rights reserved.
///

import Foundation
import CoreData
import PlaylistKit
import UIKit

final class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext?
    
    private var persistentContainer: NSPersistentContainer
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Scapes")
        super.init()
        persistentContainer.loadPersistentStores() { (description, error) in
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            self.managedObjectContext = self.persistentContainer.newBackgroundContext()
            completionClosure()
        }
    }
}

final class SongRepository: NSObject, Repository {
   
    typealias SectionType = PlaylistSection
    
    typealias RepositoryType = SongLinkIntermediate
    
    private var onDiffUpdate: ((NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>) -> Void)?
    private var modelUpdate: ((SongLinkIntermediate) -> Void)?
    private var modelsUpdate: (([SongLinkIntermediate]) -> Void)?
    
    
    private lazy var dataController = DataController {}
    
    private lazy var resultsController: NSFetchedResultsController<SongLink> = {
        let request = NSFetchRequest<SongLink>(entityName: "SongLink")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        let moc = dataController.managedObjectContext!
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    func all(matching predicate: NSPredicate?) -> [SongLinkIntermediate] {
        resultsController.fetchRequest.predicate = predicate
        do {
            try resultsController.performFetch()
            guard let objects = resultsController.fetchedObjects else { return [] }
            let result = objects.map { $0.intermediate }
            updateSnapshot()
            return result
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func element(for identifier: String) -> SongLinkIntermediate? {
        return nil
    }
    
    func add(element: SongLinkIntermediate) {
        let link = convert(element)
        resultsController.managedObjectContext.insert(link)
        save()
        updateSnapshot()
    }
    
    func update(element: SongLinkIntermediate) {
        save()
        updateSnapshot()
    }
    
    func update(element identifier: String, value: Any?, for keyPath: String) {
        
    }
    
    func delete(element: SongLinkIntermediate) {
        let link = convert(element)
        resultsController.managedObjectContext.delete(link)
        save()
        updateSnapshot()
    }
    
    func search(predicate: NSPredicate) -> SongLinkIntermediate? {
        return nil
    }
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([SongLinkIntermediate]) -> Void, onChange: @escaping (ModelsChange) -> Void){
        self.onDiffUpdate = onChange
        self.modelsUpdate = onInitial
        let objects = all(matching: filter)
        onInitial(objects)
    }

    func subscribe(entity: SongLinkIntermediate, onChange: @escaping (SongLinkIntermediate) -> Void) {
        
    }
    
    private func updateSnapshot() {
        guard let onDiffUpdate = onDiffUpdate else { return }
        let diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>()
        diffableDataSourceSnapshot.appendSections([.items])
        diffableDataSourceSnapshot.appendItems(resultsController.fetchedObjects?.compactMap({ $0.intermediate }) ?? [])
        onDiffUpdate(diffableDataSourceSnapshot)
    }
    
}

extension SongRepository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
    
    private func convert(_ songLink: SongLinkIntermediate) -> SongLink {
        let link = NSEntityDescription.insertNewObject(forEntityName: "SongLink", into: resultsController.managedObjectContext) as! SongLink
        link.setValue("\(songLink.localPlaylistItemId)", forKeyPath: "localPlaylistIdentifier")
        link.setValue(songLink.identifier, forKeyPath: "identifier")
        link.setValue(songLink.artist, forKeyPath: "artist")
        link.setValue(songLink.title, forKeyPath: "title")
        link.setValue(songLink.album, forKeyPath: "album")
        link.setValue(songLink.url, forKeyPath: "url")
        link.setValue(songLink.originalUrl, forKeyPath: "originalURL")
        link.setValue(Int64(songLink.index), forKeyPath: "index")
        link.setValue(songLink.notFound, forKeyPath: "notFound")
        link.setValue(Int64(songLink.playcount), forKeyPath: "playCount")
        link.setValue(songLink.downloaded, forKeyPath: "downloaded")
        link.setValue(songLink.artwork, forKeyPath: "artwork")
        return link
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
