//
//  PlaylistContainerIViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistContainerViewController: UIViewController {
    
    private var viewModel: PlaylistContainerViewModelProtocol
    
    private lazy var containerView: PlaylistContainerView = {
        return PlaylistContainerView()
    }()
    
    init(viewModel: PlaylistContainerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = containerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        configureListView()
    }
    
    // MARK: - View setup
    
    private func configureDetailView() {
        guard let playlist = self.viewModel.playlist.value else { return }
        let viewModel = PlaylistDetailViewModel(playlist: playlist)
        let detail = PlaylistDetailViewController(viewModel: viewModel)
        add(detail) { view in
            self.containerView.addDetailView(view)
        }
    }
    
    private func configureListView() {
        guard let playlist = self.viewModel.playlist.value else { return }
        let viewModel = PlaylistViewModel(playlist: playlist)
        let detail = PlaylistViewController(viewModel: viewModel)
        add(detail) { view in
            self.containerView.addListView(view)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }
}
extension UIViewController {
    func add(_ viewController: UIViewController, subview: (UIView) -> Void) {
        willMove(toParent: viewController)
        addChild(viewController)
        subview(viewController.view)
        didMove(toParent: viewController)
    }
    
    func remove() {
        view.removeFromSuperview()
        removeFromParent()
    }
}
