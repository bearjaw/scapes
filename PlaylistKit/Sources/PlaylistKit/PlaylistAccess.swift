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
    
    static let queue = DispatchQueue(label: "com.scapes.playlist.fetch.queue", qos: .background, attributes: .concurrent, target: .global(qos: .background))
    
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
        queue.async {
            let query = MPMediaQuery.playlists()
            guard let collections = query.collections else { onResult(.success([])); return }
            onResult(.success(collections))
        }
    }
    
    static func fetchPlaylist(forIdentifier identifier: UInt64) -> MPMediaItemCollection? {
        let predicate = MPMediaPropertyPredicate(value: identifier, forProperty: "persistentID")
        let playlist = MPMediaQuery.playlists()
        playlist.addFilterPredicate(predicate)
        return playlist.collections?.first
    }
    
    static func fetchCurrentYear(completion: @escaping ([MPMediaItem]) -> Void) {
        queue.async {
            let date = Date()
            let query = MPMediaQuery.songs().items?.filter { $0.lastPlayedDate?.isInSameYear(date) ?? false }
            completion(query ?? [])
        }
    }
    
    static func playlistArtwork(forIdentifier identifier: UInt64, size: CGSize = CGSize(width: 15, height: 15)) -> Data? {
        let playlist = fetchPlaylist(forIdentifier: identifier)
        let data = playlist?.representativeItem?.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        let image = data?.image(at: size)?.pngData()
        return image
    }
}
