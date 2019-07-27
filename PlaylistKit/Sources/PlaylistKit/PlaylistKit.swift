
import MediaPlayer

final public class PlaylistKit {
    
    static func fetchPlaylist(source: MusicSource, playlists: @escaping (Result<[CorePlaylist], Error>, songs: () -> Void) -> Void) {
        PlaylistAccess.fetchPlaylists(source: source) { result in
            switch result {
            case .success(let items):
                let parser = PlaylistParser()
                let parser.parse(collections: items, includingSongs: false)
            case .failure(let error):
                dump(error)
            }
        }
    }
}
