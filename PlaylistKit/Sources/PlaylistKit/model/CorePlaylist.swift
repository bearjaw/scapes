//
//  CorePlaylist.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation

public struct CorePlaylist: Codable {
    
    public init(name: String?, itemCount: Int) {
        self.name = name
    }
    var name: String?
    var itemCount: Int = 0
    let identifier: UUID = UUID()
    var items: [String] = []
}
