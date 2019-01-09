//
//  MusicAssetManager.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

public typealias JSON = [String: Any]

#if os(iOS)
import UIKit
#endif

#if os(watchOS)
import Foundation
#endif

final class MusicAssetManager: NetworkSession {
    static let shared = MusicAssetManager()
    
    private override init(urlSessionConfiguration: URLSessionConfiguration) {
        fatalError("Not implemented, use `init()`")
    }
    
    private init() {
        queue = {
            let oq = OperationQueue()
            oq.maxConcurrentOperationCount = 1
            oq.qualityOfService = .userInitiated
            return oq
        }()
        
        let urlSessionConfiguration: URLSessionConfiguration = {
            let c = URLSessionConfiguration.default
            c.allowsCellularAccess = true
            c.httpCookieAcceptPolicy = .never
            c.httpShouldSetCookies = false
            c.httpAdditionalHeaders = MusicAssetManager.commonHeaders
            c.requestCachePolicy = .reloadIgnoringLocalCacheData
            return c
        }()
        super.init(urlSessionConfiguration: urlSessionConfiguration)
    }
    
    //    Local stuff
    
    fileprivate var queue: OperationQueue
}

extension MusicAssetManager {
    // MARK: - Endpoint wrappers
    enum Path {
        case playlist
        case search(term: String?)
        
        fileprivate var method: NetworkHTTPMethod {
            return .GET
        }
        
        private var headers: [String: String] {
            var h: [String: String] = [:]
            
            switch self {
            default:
                h["Accept"] = "application/json"
            }
            
            return h
        }
        
        private var url: URL {
            var url = MusicAssetManager.shared.baseURL
            
            switch self {
            case .playlist:
                url.appendPathComponent("")
            case .search(let term):
                
                if let term = term {
                    if let compoundUrl = URLComponents(scheme: "https",
                                                       host: "itunes.apple.com",
                                                       path: "/search",
                                                       queryItems: [URLQueryItem(name: "term", value: term),
                                                                    URLQueryItem(name: "entity",
                                                                                 value: "musicTrack")]).url {
                        
                        url = compoundUrl
                    }
                }
            }
            
            return url
        }
        
        private var params: [String: Any] {
            var p: [String: Any] = [:]
            
            switch self {
            case .search(let term):
                p["term"] = term
            default:
                break
            }
            
            return p
        }
        
        private var queryItems: [URLQueryItem] {
            var arr: [URLQueryItem] = []
            
            for (key, value) in params {
                let qi = URLQueryItem(name: key, value: "\( value )")
                arr.append( qi )
            }
            
            return arr
        }
        
        private func jsonEncoded(params: JSON) -> Data? {
            return try? JSONSerialization.data(withJSONObject: params)
        }
        
        fileprivate var urlRequest: URLRequest {
            guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                fatalError("Invalid path-based URL")
            }
            comps.queryItems = queryItems
            
            //            guard let finalURL = comps.url else {
            //                fatalError("Invalid query items...(probably)")
            //            }
            
            var req = URLRequest(url: url)
            req.httpMethod = method.rawValue
            req.allHTTPHeaderFields = headers
            
            switch method {
            case .POST:
                req.httpBody = jsonEncoded(params: params)
            default:
                break
            }
            
            return req
        }
    }
}

extension MusicAssetManager {
    typealias ServiceCallback = ( JSON?, MusicAssetManagerError? ) -> Void
    
    func call(path: Path, callback: @escaping ServiceCallback) {
        let urlRequest = path.urlRequest
        execute(urlRequest, path: path, callback: callback)
    }
}

fileprivate extension MusicAssetManager {
    // MARK: - Common params and types
    var baseURL: URL {
        guard let url = URL(string: "https://itunes.apple.com/") else { fatalError("Can't create base URL!") }
        return url
    }
    
    static let commonHeaders: [String: String] = {
        return [
            "User-Agent": userAgent,
            "Accept-Charset": "utf-8",
            "Accept-Encoding": "gzip, deflate"
        ]
    }()
    
    static var userAgent: String = {
        // Not implemented
        return ""
    }()
    
    // MARK: - Execution
    func execute(_ urlRequest: URLRequest, path: Path, callback: @escaping ServiceCallback) {
        let op = NetworkOperation(urlRequest: urlRequest, urlSession: urlSession) { payload in
            
            if let tsStart = payload.tsStart, let tsEnd = payload.tsEnd {
                let period = tsEnd.timeIntervalSince(tsStart) * 1000
                print("\tURL: \( urlRequest.url?.absoluteString ?? "" )\n\t⏱: \( period ) ms")
            }
            
            //    process the returned stuff, now
            if let error = payload.error {
                callback(nil, MusicAssetManagerError.network(error) )
                return
            }
            
            guard let httpURLResponse = payload.response else {
                callback(nil, MusicAssetManagerError.invalidResponseType)
                return
            }
            
            if !(200...299).contains(httpURLResponse.statusCode) {
                switch httpURLResponse.statusCode {
                default:
                    callback(nil, MusicAssetManagerError.invalidResponseType)
                }
                return
            }
            
            guard let data = payload.data else {
                if path.method.allowsEmptyResponseData {
                    callback(nil, nil)
                    return
                }
                callback(nil, MusicAssetManagerError.emptyResponse)
                return
            }
            
            guard
                let obj = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                else {
                    //    convert to string, so it logged what‘s actually returned
                    let str = String(data: data, encoding: .utf8)
                    callback(nil, MusicAssetManagerError.unexpectedResponse(httpURLResponse, str))
                    return
            }
            
            switch path {
            case .playlist:
                guard let jsons = obj as? [JSON] else {
                    callback(nil, MusicAssetManagerError.unexpectedResponse(httpURLResponse, nil))
                    return
                }
                callback(["promotions": jsons], nil)
                
            default:
                guard let json = obj as? JSON else {
                    callback(nil, MusicAssetManagerError.unexpectedResponse(httpURLResponse, nil))
                    return
                }
                callback(json, nil)
            }
        }
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(op)
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
