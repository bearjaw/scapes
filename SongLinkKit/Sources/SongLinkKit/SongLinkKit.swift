//
//  SongLinkKit.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//
import Foundation

final public class SongLinkKit: NSObject {
    private var service: NetworkService?
    
    public func fetchSongs(_ items: [CoreRequest], update: @escaping (CoreSongLink) -> Void, completion: ([CoreSongLink]) -> Void) {
        service = NetworkService()
        try! service!.fetchSong(items.first!) { result in
            switch result {
            case .success(let song):
                update(song)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
}
