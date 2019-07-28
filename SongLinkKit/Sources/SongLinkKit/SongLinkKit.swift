//
//  SongLinkKit.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//
import Foundation

final public class SongLinkKit: NSObject {
    
    private var service: NetworkService
    
    public override init() {
        service = NetworkService()
        super.init()
    }
    
    public func fetchSongs(_ items: [CoreRequest], update: @escaping (CoreSongLink) -> Void, completion: ([CoreSongLink]) -> Void) {
        service = NetworkService()
        do {
            try items.forEach { try service.fetchSong($0) { result in
                switch result {
                case .success(let link):
                    update(link)
                case .failure(let error):
                    dump(error)
                }
                }
            }
        } catch {
            dump(error)
        }
    }
    
}
