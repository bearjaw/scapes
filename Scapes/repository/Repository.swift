//
//  Repository.swift
//  Scapes
//
//  Created by Max Baumbach on 09/01/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import RealmSwift

final class SongRepository: Repository {
    
    typealias RepositoryType = SongLinkDatabaseViewData
    
    static func saveSongLink(_ songLinkDatabaseViewData: SongLinkDatabaseViewData) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                try autoreleasepool {
                    try realm.write {
                        let songLinkModel = SongLinkModel()
                        songLinkModel.name = "\(songLinkDatabaseViewData.song) - \(songLinkDatabaseViewData.artist)"
                        songLinkModel.beid = "\(UUID.init())"
                        songLinkModel.artist = songLinkDatabaseViewData.artist
                        songLinkModel.song = songLinkDatabaseViewData.song
                        songLinkModel.album = songLinkDatabaseViewData.album
                        songLinkModel.url = songLinkDatabaseViewData.url
                        songLinkModel.originalUrl = songLinkDatabaseViewData.originalUrl
                        songLinkModel.index = songLinkDatabaseViewData.index
                        realm.add(songLinkModel)
                    }
                }
            } catch {
                print("Item could not be saved")
            }
        }
    }
    
    func getAll() -> [SongLinkDatabaseViewData] {
        do {
            let realm = try Realm()
            let allSongLinkModels = realm.objects(SongLinkModel.self)
           return allSongLinkModels.map { (model) -> SongLinkDatabaseViewData in
                 let song = SongLinkDatabaseViewData(artist: model.artist,
                                                     song: model.song,
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
    
    func get(identifier: String) -> SongLinkDatabaseViewData? {
        return nil
    }
    
    func add(a: SongLinkDatabaseViewData) -> Bool {
        return true
    }
    
    func update(a: SongLinkDatabaseViewData) -> Bool {
        return true
    }
    
    func delete(a: SongLinkDatabaseViewData) -> Bool {
        return true
    }
    
    func search(predicate: NSPredicate) -> SongLinkDatabaseViewData? {
        do {
            let realm = try Realm()
            let cachedSong = realm.objects(SongLinkModel.self).filter(predicate)
            
            if cachedSong.count == 1 {
                guard let model = cachedSong.first else { fatalError("Collection is empty.") }
                let songLinkViewData = SongLinkDatabaseViewData(artist: model.artist,
                                                    song: model.song,
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
}

struct SongLinkDatabaseViewData {
    let artist: String
    let song: String
    let album: String
    let url: String
    let originalUrl: String
    let index: Int
}

extension SongLinkDatabaseViewData: Equatable {
    static func == (lhs: SongLinkDatabaseViewData, rhs: SongLinkDatabaseViewData) -> Bool {
        return (lhs.song == rhs.song && lhs.artist == rhs.artist && lhs.album == rhs.album)
    }
}

protocol Repository {
    
    associatedtype RepositoryType
    
    func getAll() -> [RepositoryType]
    func get( identifier: String ) -> RepositoryType?
    func add( a: RepositoryType ) -> Bool
    func update( a: RepositoryType ) -> Bool
    func delete( a: RepositoryType ) -> Bool
    func search( predicate: NSPredicate ) -> RepositoryType?
    
}
