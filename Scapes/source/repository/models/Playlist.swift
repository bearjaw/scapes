//
//  Playlist.swift
//  Scapes
//
//  Created by Max Baumbach on 29/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

struct Playlist: Hashable, Codable {
    let name: String
    let count: Int
    let identifier: UInt64
    let artwork: Data?
}
