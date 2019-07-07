//
//  PlaylistProvider.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import MediaPlayer

final class PlaylistProvider {
    static func fetchPlaylists(onResult: @escaping (Result<[Playlist], Error>) -> Void) {
        guard MPMediaLibrary.authorizationStatus() != .authorized else {
            loadPlaylists(result: onResult)
            return
        }
        MPMediaLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                loadPlaylists(result: onResult)
            case .notDetermined:
                onResult(.failure(PlaylistError.notDetermined))
            case .denied:
                onResult(.failure(PlaylistError.denied))
            case .restricted:
                onResult(.failure(PlaylistError.restricted))
            @unknown default:
                onResult(.failure(PlaylistError.unknown))
            }
        }
    }
}

// MARK: - Playlist Parsing

private extension PlaylistProvider {
    private static func fetchSongs(for playlist: MPMediaItemCollection) -> [SongLink] {
        guard playlist.items.isNonEmpty else { return [] }
        var index = 0
        var songs: [SongLink] = []
        for song in playlist.items {
            if let title: String = song.value(forProperty: MPMediaItemPropertyTitle) as? String,
                let artist: String = song.value(forProperty: MPMediaItemPropertyArtist) as? String,
                let album: String = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String,
                let playcount: NSNumber = song.value(forProperty: MPMediaItemPropertyPlayCount) as? NSNumber,
                let artwork: MPMediaItemArtwork = song.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
//                let data = Data( artwork.image(at: CGSize(width: 200, height: 200)))
                let songLink = SongLink(id: UUID().uuidString,
                                        artist: artist,
                                        title: title,
                                        album: album,
                                        url: "",
                                        originalUrl: "",
                                        index: index,
                                        notFound: false,
                                        playcount: playcount.intValue,
                                        downloaded: false,
                                        playlistHash: String(playlist.persistentID),
                                        artwork: nil)
                songs.append(songLink)
            }
            index += 1
        }
        return songs
    }
    
    private static func loadPlaylists(result: @escaping (Result<[Playlist], Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let query = MPMediaQuery.playlists()
            guard let collections = query.collections else { result(.success([])); return }
            let playlist = collections.map { collection -> Playlist in
                let name = (collection.value(forProperty: MPMediaPlaylistPropertyName) as? String) ?? ""
                let songs = fetchSongs(for: collection)
                return Playlist(name: name, count: collection.count, items: songs)
            }
            DispatchQueue.main.async {
                result(.success(playlist))
            }
        }
    }
}

// MARK: - Playlist Error

protocol Loggable: Error {
    var reason: String { get }
}

enum PlaylistError: Loggable {
    case notDetermined
    case denied
    case restricted
    case unknown
    
    var reason: String {
        switch self {
        case .notDetermined:
            return "Could not determine auth status"
        case .denied:
            return "Access to media library is denied"
        case .restricted:
            return "Access to media library is restricted"
        case .unknown:
            return "Unknown error occured."
        }
    }
}
