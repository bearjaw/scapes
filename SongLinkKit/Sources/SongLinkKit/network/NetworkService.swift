//
//  NetworkService.swift
//  
//
//  Created by Max Baumbach on 28/07/2019.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case GET, POST
    case HEAD, PUT, DELETE
    case OPTIONS, TRACE, CONNECT
    
    var allowsEmptyResponseData: Bool {
        switch self {
        case .GET, .POST:
            return false
        default:
            return true
        }
    }
}

@available(iOS 13.0, *)
final class NetworkService: NSObject {
    typealias JSON = [String: Any]
    
    private var cancel: AnyCancellable?
    
    func fetchSong(_ song: CoreRequest, onCompleted: @escaping (Result<CoreSongLink, Error>) -> Void) throws {
        var request = URLRequest(url: song.appleURL)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = ["Accept": "application/json"]
        
        cancel = URLSession.shared.dataTaskPublisher(for: request)
            .tryCatch { error -> URLSession.DataTaskPublisher in
                guard error.networkUnavailableReason == .constrained else { throw error }
                return URLSession.shared.dataTaskPublisher(for: request)
        }
        .tryMap { (data, response) -> CoreSongLink? in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return nil }
            guard let json: JSON = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? JSON else { return nil }
            let result: [JSON] = json["results"] as! [JSON]
            guard let content = result.first else { return nil }
            let trackViewUrl = content["trackViewUrl"] as? String ?? ""
            let songLinkURL = "https://song.link/\(trackViewUrl)&app=music"
            return song.generateCoreSongLink(from: songLinkURL, trackViewURL: trackViewUrl)
        }
        .sink(receiveCompletion: { error in
            onCompleted(.failure(NetworkError.failed))
        }, receiveValue:  { songLink in
            onCompleted(.success(songLink!))
        })
    }
}

extension URLComponents {
    init(scheme: String, host: String, path: String, queryItems: [URLQueryItem]) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }
}

enum NetworkError: Error {
    case failed
}
