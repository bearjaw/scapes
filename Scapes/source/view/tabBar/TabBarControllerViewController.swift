//
//  TabBarViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 07/12/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createModules()
    }
    
    // MARK: - View Setup
    
    private func createModules() {
        let playlist = createPlaylistsModule()
        let analysis = createMusicAnalysisModule()
        viewControllers = [playlist, analysis]
    }
    
    private func createPlaylistsModule() -> UIViewController {
        let plugin = FetchPlaylistsPlugin()
        let viewModel = PlaylistsViewModel(plugins: [plugin])
        let viewController = PlaylistsTableViewController(viewModel: viewModel)
        return wrapInNavigationViewController(viewController)
    }
    
    private func createMusicAnalysisModule() -> UIViewController {
        let plugin = FetchSongsPlugin()
        let viewModel = MusicAnalysisViewModel(plugins: [plugin])
        let viewController = MusicAnalysisViewController(viewModel: viewModel)
        return wrapInNavigationViewController(viewController)
    }
    
    private func wrapInNavigationViewController(_ viewController: UIViewController) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

}
