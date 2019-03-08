//
//  SongLinkRepository.swift
//  Scapes
//
//  Created by Max Baumbach on 04/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import RealmSwift

final class SongRepository: Repository {
    
    typealias RepositoryType = SongLink
    typealias Token = RepoToken
    
    func all(matching predicate: NSPredicate?) -> [SongLink] {
        guard let predicate = predicate else { return [] }
        let items = realm.objects(RealmSongLink.self).filter(predicate).sorted(byKeyPath: "index")
        return items.map { convert(element: $0) }
    }
    
    func element(for identifier: String) -> SongLink? {
        guard let result = realm.object(ofType: RealmSongLink.self, forPrimaryKey: identifier) else {
            return nil
        }
        return convert(element: result)
    }
    
    func add(element: SongLink) {
        safeWrite {
            realm.create(RealmSongLink.self, value: convert(element: element), update: true)
        }
    }
    
    func update(element: SongLink) {
        safeWrite {
            realm.create(RealmSongLink.self, value: convert(element: element), update: true)
        }
    }
    
    func delete(element: SongLink) {
        safeWrite {
            realm.delete(convert(element: element))
        }
    }
    
    func search(predicate: NSPredicate) -> SongLink? {
        let results = realm.objects(RealmSongLink.self).filter(predicate)
        let songLinks: [SongLink] = results.map { convert(element: $0 )}
        return songLinks.first
    }
    
    func subscribe(filter: NSPredicate? = nil, onInitial: @escaping ([SongLink]) -> Void,
                   onChange: @escaping ([SongLink], Indecies) -> Void) -> RepoToken? {
        var results = realm.objects(RealmSongLink.self)
        if let filter = filter {
            results = results.filter(filter)
        }
        return RepoToken(
            results.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                case .initial(let collection):
                    onInitial(collection.sorted(byKeyPath: "index").map({ self.convert(element: $0 )}))
                case .update(let collection, let deletions, let insertions, let modifications):
                    print("")
                    onChange(collection.map({ self.convert(element: $0 )}),
                             (deletions: deletions, insertions: insertions, modifications: modifications))
                case .error(let error):
                    fatalError("\(error)")
                }
        })
    }
    
    func subscribe(entity: SongLink, onChange: @escaping (SongLink) -> Void) -> RepoToken? {
        guard let model = realm.object(ofType: RealmSongLink.self, forPrimaryKey: entity.id) else {
            fatalError("Could not fetch model. Id did not match any entities.")
        }
        return RepoToken(
            model.observe { [unowned self] change in
                switch change {
                case .change:
                    onChange(self.convert(element: model))
                case .error(let error):
                    print("An error occurred: \(error)")
                case .deleted:
                    print("The object was deleted.")
                }
        })
    }
}

extension SongRepository {
    private var realm: Realm {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        guard let realm = try? Realm(configuration: config) else {
            fatalError("Could not create database instance.")
        }
        return realm
    }
}

extension SongRepository {
    private func convert(element: RealmSongLink) -> SongLink {
        return SongLink( id: element.id,
                         artist: element.artist,
                         title: element.title,
                         album: element.album,
                         url: element.url,
                         originalUrl: element.originalUrl,
                         index: element.index,
                         notFound: element.notFound,
                         playcount: element.playcount,
                         downloaded: element.downloaded,
                         playlistHash: element.playlistHash)
    }
    
    private func convert(element: SongLink) -> RealmSongLink {
        let model = RealmSongLink()
        model.id = element.id
        model.itemId = "\(element.album) \(element.artist) \(element.title)"
        model.artist = element.artist
        model.title = element.title
        model.album = element.album
        model.url = element.url
        model.originalUrl = element.originalUrl
        model.index = element.index
        model.notFound = element.notFound
        model.playcount = element.playcount
        model.downloaded = element.downloaded
        model.playlistHash = element.playlistHash
        return model
    }
    
    private func safeWrite(_ write: () -> Void) {
        do {
            try realm.write {
                write()
            }
        } catch {
            fatalError("Could not open write transaction")
        }
    }
}
