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
    
    func search(in songs: [Song], result: @escaping Result) {
        self.downloadSongLinks(songs: songs, result: result)
    }
    
    func provideCachedSongs(for playlist: Playlist, content: @escaping Content) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = self?.checkForAvailableSongs(songs: playlist.items) {
                let cache = data.0
                let remainingSongs = data.1
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
    
    private func downloadSongLinks(songs: [Song], result: @escaping Result) {
        var results: [SongLinkViewData] = []
        for song in songs {
            self.search(song: song, searchBlock: { item, songData in
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
                DispatchQueue.main.async {
                    if results.count == songs.count {
                        result(results)
                    }
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
        let songLinkData = SongLinkDatabaseViewData(
            artist: song.artist,
            song: song.title,
            album: song.albumTitle,
            url: url,
            originalUrl: originalUrl,
            index: song.index
        )
        let songRepo = SongRepository()
        _ = songRepo.add(element: songLinkData)
    }
    
    private func checkForAvailableSongs(songs: [Song]) -> ([SongLinkViewData], [Song] ) {
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
                                                    title: cachedSong.song,
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
