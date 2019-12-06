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
import os

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
            #if targetEnvironment(simulator)
//            self.deleteDebugData()
            #endif
            completionClosure()
        }
    }
    
    private func deleteDebugData() {
        let fetchRequest = NSFetchRequest<SongLink>(entityName: "SongLink")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try self.managedObjectContext?.execute(deleteRequest)
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            os_log("Error: %@", error)
        }
    }
}

final class SongRepository: NSObject {
    
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
    
    private func all(_ matching: NSPredicate) -> [SongLink] {
        let fetchRequest = NSFetchRequest<SongLink>(entityName: "SongLink")
        fetchRequest.predicate = matching
        fetchRequest.sortDescriptors = resultsController.fetchRequest.sortDescriptors
        do {
            guard let objects = try dataController.managedObjectContext?.fetch(fetchRequest) else { return [] }
            return objects
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    private func search(_ predicate: NSPredicate) -> SongLink? {
        let request = NSFetchRequest<SongLink>(entityName: "SongLink")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            return try resultsController.managedObjectContext.fetch(request).first
        } catch {
            os_log("%@", error.localizedDescription)
        }
        return nil
    }
    
    private func updateSnapshot() {
        guard let onDiffUpdate = onDiffUpdate else {
            os_log("No sub")
            return
        }
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<PlaylistSection, SongLinkIntermediate>()
        diffableDataSourceSnapshot.appendSections([.items])
        try? self.resultsController.performFetch()
        diffableDataSourceSnapshot.appendItems(self.resultsController.fetchedObjects?.compactMap({ $0.intermediate }) ?? [])
        onDiffUpdate(diffableDataSourceSnapshot)
    }
    
}

extension SongRepository: Repository {
    
    func all(matching predicate: NSPredicate?) -> [SongLinkIntermediate] {
        guard let predicate = predicate else { return [] }
        return self.all(predicate).map { $0.intermediate }
    }
    
    func search(predicate: NSPredicate) -> SongLinkIntermediate? {
        return self.search(predicate)?.intermediate
    }
    
    func element(for identifier: String) -> SongLinkIntermediate? {
        let predicate = NSPredicate(format: "localPlaylistItemIdentifier == %@", identifier)
        return search(predicate: predicate)
    }
    
    func add(elements: [SongLinkIntermediate]) {
        elements.forEach { add(element: $0) }
    }
    
    func add(element: SongLinkIntermediate) {
        let link = convert(element)
        if search(element) == nil {
            resultsController.managedObjectContext.insert(link)
        }
        save()
    }
    
    func update(element: SongLinkIntermediate) {
        _ = convert(element)
        save()
    }
    
    func delete(element: SongLinkIntermediate) {
        let link = convert(element)
        resultsController.managedObjectContext.delete(link)
        save()
    }
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([SongLinkIntermediate]) -> Void, onChange: @escaping (ModelsChange) -> Void){
        self.onDiffUpdate = onChange
        self.modelsUpdate = onInitial
        let objects = all(matching: filter)
        onInitial(objects)
    }
    
    func subscribe(entity: SongLinkIntermediate, onChange: @escaping (SongLinkIntermediate) -> Void) {
        
    }
    
    func applyGlobalFilter(_ predicate: NSPredicate) {
        resultsController.fetchRequest.predicate = predicate
        do {
            try resultsController.performFetch()
        } catch {
            os_log("Could perform fetch request. Predicate was: %@", predicate.predicateFormat)
        }
    }
}

extension SongRepository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
    
    private func convert(_ songLink: SongLinkIntermediate) -> SongLink {
        let link: SongLink
        if  let update = search(songLink) {
            link = update
            let url = songLink.url.isEmpty ? link.url : songLink.url
            let originalURL = songLink.originalUrl.isEmpty ? link.originalURL : songLink.originalUrl
            link.setValue(url, forKeyPath: "url")
            link.setValue(originalURL, forKeyPath: "originalURL")
            link.setValue(songLink.notFound, forKeyPath: "notFound")
            link.setValue(songLink.downloaded, forKeyPath: "downloaded")
        } else {
            link = NSEntityDescription.insertNewObject(forEntityName: "SongLink", into: resultsController.managedObjectContext) as! SongLink
            link.setValue(songLink.url, forKeyPath: "url")
            link.setValue(songLink.originalUrl, forKeyPath: "originalURL")
            link.setValue(songLink.notFound, forKeyPath: "notFound")
            link.setValue(songLink.downloaded, forKeyPath: "downloaded")
        }
        link.setValue("\(songLink.localPlaylistItemId)", forKeyPath: "localPlaylistItemIdentifier")
        link.setValue(songLink.identifier, forKeyPath: "identifier")
        link.setValue(songLink.artist, forKeyPath: "artist")
        link.setValue(songLink.title, forKeyPath: "title")
        link.setValue(songLink.album, forKeyPath: "album")
        link.setValue(Int64(songLink.index), forKeyPath: "index")
        
        link.setValue(Int64(songLink.playcount), forKeyPath: "playCount")
        
        link.setValue(songLink.artwork, forKeyPath: "artwork")
        return link
    }
}

// MARK: Convenience methods

extension SongRepository {
    private func save() {
        os_log("Called save")
        guard resultsController.managedObjectContext.hasChanges else { return }
        do {
            try resultsController.managedObjectContext.save()
            updateSnapshot()
        } catch {
            fatalError("Error: Could not save managed object context")
        }
    }
    
    private func search(_ element: SongLinkIntermediate) -> SongLink? {
        let predicate = element.query
        return search(predicate)
    }
}
