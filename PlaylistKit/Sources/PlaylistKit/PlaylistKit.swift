import Foundation

public enum MediaItemType {
    case playlist(identifier: UInt64)
    case song(identifier: UInt64)
}

final public class PlaylistKit {
    
    public static func fetchPlaylist(source: MusicSource, playlists: @escaping (Result<[CorePlaylist], Error>) -> Void) {
        PlaylistAccess.fetchPlaylists(source: source) { result in
            switch result {
            case let .success(items):
                let parser = PlaylistParser()
                let parsed = parser.parse(collections: items)
                playlists(.success(parsed))
            case let .failure(error):
                playlists(.failure(error))
            }
        }
    }
    
    public static func fetchSongs(forPlaylist identifier: UInt64, songs: (Result<[CorePlaylistItem], MusicKitError>) -> Void) {
        guard let playlist = PlaylistAccess.fetchPlaylist(forIdentifier: identifier) else {
            songs(.failure(.notFound(identifier)))
            return
        }
        let parser = PlaylistParser()
        let result = parser.parseSongs(forPlaylist: playlist)
        songs(.success(result))
    }
    
    public static func fetchArtwork(forType type: MediaItemType) -> Data? {
        switch type {
        case let .playlist(identifier):
            return PlaylistAccess.playlistArtwork(forIdentifier: identifier)
        case .song:
            return nil
        }
    }
    
    public static func fetchSongsHeardInCurrentYear(songs: @escaping (Result<[CorePlaylistItem], MusicKitError>) -> Void) {
        PlaylistAccess.fetchCurrentYear { items in
            let parser = PlaylistParser()
            let result = parser.parse(songs: items)
            songs(.success(result))
        }
    }
    
}
