//
//  DatabaseManager.swift
//  Scapes
//
//  Created by Max Baumbach on 19/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit
import RealmSwift

final class DatabaseManager: NSObject {
    
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
    
    static func search(song: Song) -> SongLinkViewData? {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "artist = %@ AND album = %@ AND song = %@",
                                        song.artist,
                                        song.albumTitle,
                                        song.title)
            
            let cachedSong = realm.objects(SongLinkModel.self).filter(predicate)
            
            if cachedSong.count == 1 {
                guard let model = cachedSong.first else { fatalError("Collection is empty.")}
                let songLinkViewData = SongLinkViewData(url: model.url,
                                                        success: true,
                                                        title: model.song,
                                                        artist: model.artist,
                                                        album: song.albumTitle,
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
