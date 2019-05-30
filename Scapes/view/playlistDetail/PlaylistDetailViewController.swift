//
//  PlaylistDetailViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistDetailViewController: UIViewController {
    
    private lazy var viewDetail: PlaylistDetailView = { return PlaylistDetailView() }()
    private var viewModel: PlaylistDetailViewModelProtocol
    
    init(viewModel: PlaylistDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = viewDetail
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeTitleChanges()
    }
    
    // MARK: - View setup
    
    private func observeTitleChanges() {
        viewModel.title.observe { [unowned self] newValue in
            self.viewDetail.update(title: newValue, thumbnail: nil)
        }
    }
}
