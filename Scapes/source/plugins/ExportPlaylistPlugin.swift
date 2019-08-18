//
//  ExportPlaylistPlugin.swift
//  Scapes
//
//  Created by Max Baumbach on 18/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

final class ExportPlaylistPlugin: NSObject {
    
    func exportPlaylist(_ playlist: Playlist, songs: [SongLinkIntermediate], onCompletion: @escaping (Bool) -> Void) {
        var exportString = playlist.name
        DispatchQueue.global(qos: .userInitiated).async {
            for item in songs {
                if item.url.isEmpty {
                    exportString.append(contentsOf: "\(item.title) \(item.artist) \n Couldn't find that song.")
                } else {
                    exportString.append(contentsOf: "\(item.title) - \(item.artist) \n URL: \(item.url) \n\n")
                }
            }
            DispatchQueue.main.async {
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = exportString
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                onCompletion(true)
            }
        }
    }
}

extension ExportPlaylistPlugin: Plugin {
    var type: Int { ScapesPluginType.export.rawValue }
}
