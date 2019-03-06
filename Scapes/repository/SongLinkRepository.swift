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
    
    static func saveSongLink(_ songLink: SongLink) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let realm = try Realm()
                try autoreleasepool {
                    try realm.write {
                        let songLinkModel = RealmSongLink()
                        songLinkModel.title = "\(songLink.title) - \(songLink.artist)"
                        songLinkModel.id = songLink.id
                        songLinkModel.artist = songLink.artist
                        songLinkModel.song = songLink.title
                        songLinkModel.album = songLink.album
                        songLinkModel.url = songLink.url
                        songLinkModel.originalUrl = songLink.originalUrl
                        songLinkModel.index = songLink.index
                        realm.add(songLinkModel)
                    }
                }
            } catch {
                print("Item could not be saved")
            }
        }
    }
    
    func getAll() -> [SongLink] {
        do {
            let realm = try Realm()
            let results = realm.objects(RealmSongLink.self)
            return results.map({ convert(element: $0) })
        } catch {
            print("Could access all Songs")
        }
        return []
    }
    
    func get(identifier: String) -> SongLink? {
        return nil
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
        do {
            let realm = try Realm()
            let cachedSong = realm.objects(RealmSongLink.self).filter(predicate)
            
            if cachedSong.count == 1 {
                guard let model = cachedSong.first else { fatalError("Collection is empty.") }
                let songLinkViewData = SongLink(id: UUID().uuidString,
                                                artist: model.artist,
                                                title: model.song,
                                                album: model.album,
                                                url: model.url,
                                                originalUrl: model.originalUrl,
                                                index: model.index,
                                                notFound: model.notFound
                )
                return songLinkViewData
            }
        } catch {
            print("error occured")
        }
        return nil
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
                    onInitial(collection.map({ self.convert(element: $0 )}))
                case .update(let collection, let deletions, let insertions, let modifications):
                    print("")
                    onChange(collection.sorted(byKeyPath: "index").map({ self.convert(element: $0 )}),
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
                         notFound: element.notFound)
    }
    
    private func convert(element: SongLink) -> RealmSongLink {
        let model = RealmSongLink()
        model.id = element.id
        model.artist = element.artist
        model.title = element.title
        model.album = element.album
        model.url = element.url
        model.originalUrl = element.originalUrl
        model.index = element.index
        model.notFound = element.notFound
        return model
    }
    
    private func safeWrite(_ write:() -> Void) {
        do {
            try realm.write {
                write()
            }
        } catch {
            fatalError("Could not open write transaction")
        }
    }
}
