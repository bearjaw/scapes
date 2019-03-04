//
//  SongLinkViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 04/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

protocol SongLinkViewModelProtocol {
    var items: [SongLinkViewData] { get }
    func subscribe(onInitial: () -> Void, onChange: () -> Void)
    
}

final class SongLinkViewModel: SongLinkViewModelProtocol {
    var items: [SongLinkViewData] = []
    private var playlist: Playlist?
    private var remainingSongs: [Song] = []
    
    func subscribe(onInitial: () -> Void, onChange: () -> Void) {
        
    }
    
    private lazy var service: SongLinkProvider = {
        return SongLinkProvider()
    }()
    
    
}
