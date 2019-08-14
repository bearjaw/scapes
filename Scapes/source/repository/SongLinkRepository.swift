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

final class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext?
    
    private var persistentContainer: NSPersistentContainer
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Scapes")
        super.init()
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            self.managedObjectContext = self.persistentContainer.newBackgroundContext()
            completionClosure()
        }
    }
}

final class SongRepository: NSObject, Repository {
    
    typealias RepositoryType = SongLinkIntermediate
    
    typealias Token = String
    
    private var modelsIndexUpdate: ((ModelsChange) -> Void)?
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
            let result = objects.map { convert($0) }
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
    }
    
    func update(element: SongLinkIntermediate) {
        save()
    }
    
    func saveObjects() {
        save()
    }
    
    func update(element identifier: String, value: Any?, for keyPath: String) {
        
    }
    
    func delete(element: SongLinkIntermediate) {
        let link = convert(element)
        resultsController.managedObjectContext.delete(link)
        save()
    }
    
    func search(predicate: NSPredicate) -> SongLinkIntermediate? {
        return nil
    }
    
    func subscribe(filter: NSPredicate?, onInitial: @escaping ([SongLinkIntermediate]) -> Void, onChange: @escaping (ModelsChange) -> Void) -> String? {
        self.modelsIndexUpdate = onChange
        self.modelsUpdate = onInitial
        let objects = all(matching: filter)
        onInitial(objects)
        return nil
    }
    
    func subscribe(entity: SongLinkIntermediate, onChange: @escaping (SongLinkIntermediate) -> Void) -> String? {
        return nil
    }
    
}

extension SongRepository: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        guard let onChange = self.modelsUpdate, let objects = resultsController.fetchedObjects else { return }
        let result = objects.map { convert($0) }
        onChange(result)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            let result = objects.map { convert($0) }
            onChange((result, [indexPath], [], []))
        case .insert:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            let result = objects.map { convert($0) }
            onChange((result, [], [indexPath], []))
        case .update:
            guard let onChange = self.modelsIndexUpdate,
                let objects = resultsController.fetchedObjects,
                let indexPath = indexPath else { return }
            let result = objects.map { convert($0) }
            onChange((result, [], [], [indexPath]))
        case .move:
            break
        @unknown default:
            break
        }
    }
    
    private func convert(_ songLink: SongLink) -> SongLinkIntermediate {
        return SongLinkIntermediate(localPlaylistItemId: UInt64(songLink.localPlaylistIdentifier ?? "")!,
                                    identifier: songLink.identifier ?? UUID(),
                                    artist: songLink.artist ?? "",
                                    title: songLink.title ?? "",
                                    album: songLink.album ?? "",
                                    url: songLink.url ?? "",
                                    originalUrl: songLink.originalURL ?? "",
                                    index: Int(songLink.index),
                                    notFound: songLink.notFound,
                                    playcount: Int(songLink.playCount),
                                    downloaded: songLink.downloaded,
                                    artwork: songLink.artwork)
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
