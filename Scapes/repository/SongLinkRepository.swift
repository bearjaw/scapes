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
            let allSongLinkModels = realm.objects(RealmSongLink.self)
            return allSongLinkModels.map { (model) -> SongLink in
                let song = SongLink(id: model.id,
                    artist: model.artist,
                    title: model.song,
                    album: model.album,
                    url: model.url,
                    originalUrl: model.originalUrl,
                    index: model.index
                )
                return song
            }
        } catch {
            print("Could access all Songs")
        }
        return []
    }
    
    func get(identifier: String) -> SongLink? {
        return nil
    }
    
    func add(element: SongLink) -> Bool {
        return true
    }
    
    func update(element: SongLink) -> Bool {
        return true
    }
    
    func delete(element: SongLink) -> Bool {
        return true
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
                                                index: model.index
                )
                return songLinkViewData
            }
        } catch {
            print("error occured")
        }
        return nil
    }
    
    func subscribe(onInitial: ([SongLink]) -> Void, onChange: ([SongLink]) -> Void) -> RepoToken? {
        let results = realm.objects(RealmSongLink.self)
        return RepoToken(
            results.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    print("")
                case .update(_, let deletions, let insertions, let modifications):
                    print("")
                case .error(let error):
                    fatalError("\(error)")
                }
        })
    }
    
    func subscribe(entity: SongLink, onChange: (SongLink) -> Void) -> RepoToken? {
        guard let model = realm.object(ofType: RealmSongLink.self, forPrimaryKey: entity.id) else {
            fatalError("Could not fetch model. Id did not match any entities.")
        }
        return RepoToken(
            model.observe { change in
                switch change {
                case .change(let properties):
                    print("canges")
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
