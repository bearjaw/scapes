//
//  SongLinkProvider.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//
import Foundation

class SongLinkProvider: NSObject {
    
    private lazy var service: MusicAssetManager = {
        return MusicAssetManager.shared
    }()
    
    typealias SearchBlock = (_ songLinkReadyItem: SongLinkReadyItem?, _ song: Song) -> Void
    typealias Result = (_ songLinks: [SongLinkViewData]) -> Void
    
    typealias Content = (_ cache: [SongLinkViewData], _ remainingSongs: [Song]) -> Void
    
    override init() {
        super.init()
    }
    
    func search(in songs: [Song]) {
        downloadSongLinks(songs: songs)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = self?.checkForAvailableSongs(songs: playlist.items) {
                let cache = data.cache
                let remainingSongs = data.downloads
                DispatchQueue.main.async {
                    content(cache, remainingSongs)
                }   
            } else {
                DispatchQueue.main.async {
                    content([], [])
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func downloadSongLinks(songs: [Song]) {
        var results: [SongLinkViewData] = []
        for song in songs {
            self.search(song: song, searchBlock: { [unowned self] item, songData in
                if let url = item?.url, let originalUrl = item?.originalUrl {
                    results.append(SongLinkViewData(url: url,
                                                    success: true,
                                                    title: songData.title,
                                                    artist: songData.artist,
                                                    album: songData.albumTitle,
                                                    index: songData.index
                    ))
                    self.addToDatabase(song: songData, url: url, originalUrl: originalUrl)
                } else {
                    results.append(SongLinkViewData(
                        url: "Failed for \(song.title) \(song.artist)",
                        success: false,
                        title: songData.title,
                        artist: songData.artist,
                        album: songData.albumTitle,
                        index: songData.index
                    ))
                    let error = "Could not find the music track matching these criteria."
                    self.addToDatabase(song: songData, url: error, originalUrl: error)
                }
            })
        }
    }
    
    private func search(song: Song, searchBlock: @escaping SearchBlock) {
        let escapedString = "\(song.title)+\(song.artist)"
        service.call(path: MusicAssetManager.Path.search(term: escapedString), callback: { json, _ in
            if let contents: [[String: Any]] = json?["results"] as? [[String: Any]] {
                let content = contents.first
                let trackViewUrl = content?["trackViewUrl"] as? String ?? ""
                if trackViewUrl.count > 1 {
                    let newTrack: String = "https://song.link/\(trackViewUrl)&app=music"
                    print(newTrack)
                    let item = SongLinkReadyItem(url: newTrack, originalUrl: trackViewUrl)
                    searchBlock(item, song)
                } else {
                    searchBlock(nil, song)
                }
            } else {
                searchBlock(nil, song)
            }
        })
    }
    
    private func addToDatabase(song: Song, url: String, originalUrl: String) {
        let songLinkData = SongLink(
            id: UUID().uuidString,
            artist: song.artist,
            title: song.title,
            album: song.albumTitle,
            url: url,
            originalUrl: originalUrl,
            index: song.index,
            notFound: false
        )
        let songRepo = SongRepository()
        songRepo.add(element: songLinkData)
    }
    
    private func checkForAvailableSongs(songs: [Song]) -> (cache: [SongLinkViewData], downloads: [Song] ) {
        var cache: [SongLinkViewData] = []
        let songsToDownload = songs.filter({ song in
            let predicate = NSPredicate(format: "artist = %@ AND album = %@ AND song = %@",
                                        song.artist,
                                        song.albumTitle,
                                        song.title)
            let songRepo = SongRepository()
            if let cachedSong = songRepo.search(predicate: predicate) {
                let songViewData = SongLinkViewData(url: cachedSong.url,
                                                    success: true,
                                                    title: cachedSong.title,
                                                    artist: cachedSong.artist,
                                                    album: cachedSong.album,
                                                    index: cachedSong.index)
                cache.append(songViewData)
                return false
            }
            return true
        })
        return (cache, songsToDownload)
    }
}

struct SongLinkReadyItem {
    let url: String
    let originalUrl: String
}

struct SongLinkViewData: Equatable {
    let url: String
    let success: Bool
    let title: String
    let artist: String
    let album: String
    let index: Int
}

struct SongLink {
    let id: String
    let artist: String
    let title: String
    let album: String
    let url: String
    let originalUrl: String
    let index: Int
    let notFound: Bool
    
    init(artist: String, album: String, title: String) {
        self.id = ""
        self.artist = artist
        self.title = title
        self.album = album
        self.url = ""
        self.originalUrl = ""
        self.index = -1
        self.notFound = false
    }
    
    init(id: String,
         artist: String,
         title: String,
         album: String,
         url: String,
         originalUrl: String,
         index: Int,
         notFound: Bool) {
        self.id = id
        self.artist = artist
        self.title = title
        self.album = album
        self.url = url
        self.originalUrl = originalUrl
        self.index = index
        self.notFound = notFound
    }
}
