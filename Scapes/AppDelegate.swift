//
//  AppDelegate.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewModel = PlaylistsViewModel()
        let viewController = PlaylistsTableViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        navigationController.navigationBar.prefersLargeTitles = true
        configureNavbar(for: navigationController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    private func configureNavbar(for navigationController: UINavigationController) {
        let bar = UIBarAppearance(idiom: .phone)
        bar.backgroundColor = .barTint
        let navBar = UINavigationBarAppearance(barAppearance: bar)
        navBar.titleTextAttributes = [.foregroundColor: UIColor.action]
        navBar.largeTitleTextAttributes = [.foregroundColor: UIColor.action]
        navBar.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.action]
        navBar.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.action]
        navigationController.navigationBar.standardAppearance = navBar
        navigationController.navigationBar.tintColor = .action
        navigationController.navigationBar.compactAppearance = navBar
        navigationController.navigationBar.scrollEdgeAppearance = navBar
        navigationController.navigationBar.isTranslucent = false
    }
}
