//
//  PlaylistAccess.swift
//  
//
//  Created by Max Baumbach on 27/07/2019.
//

import Foundation
import MediaPlayer

public enum MusicSource {
    case local
}

final class PlaylistAccess {
    
     static func fetchPlaylists(source: MusicSource, onResult: @escaping (Result<[MPMediaItemCollection], Error>) -> Void) {
            guard MPMediaLibrary.authorizationStatus() != .authorized else {
                loadPlaylists(from: source, onResult: onResult)
                return
            }
            MPMediaLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.loadPlaylists(from: source, onResult: onResult)
                case .notDetermined:
                    onResult(.failure(AccessError.notDetermined))
                case .denied:
                    onResult(.failure(AccessError.denied))
                case .restricted:
                    onResult(.failure(AccessError.restricted))
                @unknown default:
                    onResult(.failure(AccessError.unknown))
                }
            }
        }
    
     static func loadPlaylists(from source: MusicSource, onResult: @escaping (Result<[MPMediaItemCollection], Error>) -> Void) {
        let queue = DispatchQueue(label: "com.scapes.playlist.fetch.queue", qos: .background, attributes: .concurrent, target: .global(qos: .background))
        queue.async {
            let query = MPMediaQuery.playlists()
            guard let collections = query.collections else { onResult(.success([])); return }
            onResult(.success(collections))
        }
    }
    
    static func fetchPlaylist(forIdentifier identifier: UInt64) -> MPMediaItemCollection? {
        let predicate = MPMediaPropertyPredicate(value: identifier, forProperty: "persistentID")
        let filter: Set<MPMediaPropertyPredicate> = Set(arrayLiteral: predicate)
        let query = MPMediaQuery(filterPredicates: filter)
        return query.collections?.first
    }
}
