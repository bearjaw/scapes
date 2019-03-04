//
//  SongLinkModel.swift
//  Scapes
//
//  Created by Max Baumbach on 19/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import RealmSwift

final class RealmSongLink: Object {
    @objc dynamic var id = ""
    @objc dynamic var title: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var song: String = ""
    @objc dynamic var album: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var originalUrl: String = ""
    @objc dynamic var index: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
