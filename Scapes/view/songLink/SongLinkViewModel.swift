//
//  SongLinkViewModel.swift
//  Scapes
//
//  Created by Max Baumbach on 04/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation

protocol SongLinkViewModelProtocol {
    typealias Indecies = (deletions: [Int], insertions: [Int], modifications: [Int])
    var data: [SongLinkViewData] { get }
    
    func fetchRemainingSongsIfNeeded()
    
    func subscribe(onInitial: @escaping () -> Void, onChange: @escaping (Indecies) -> Void, onEmpty: @escaping () -> Void)
    
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
