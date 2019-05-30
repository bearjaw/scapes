//
//  PlaylistDetailViewProtocol.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

protocol PlaylistDetailViewModelProtocol {
    var title: LiveData<String> { get }
}

final class PlaylistDetailViewModel {
    
    private var liveData: LiveData<String>
    
    init(playlistId: String) {
        liveData = LiveData()
    }
}

extension PlaylistDetailViewModel: PlaylistDetailViewModelProtocol {
    var title: LiveData<String> {
        return liveData
    }
}
