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
    
    lazy var appearanceSerice: AppearanceService = {
        return AppearanceService(style: .dark)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = PlaylistsTableViewController(style: .plain)
        
        let navigationVC = UINavigationController(rootViewController: viewController)
        navigationVC.navigationItem.largeTitleDisplayMode = .automatic
        navigationVC.navigationBar.prefersLargeTitles = true
        setupAppearance()
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
        return true
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().tintColor = AppearanceService.shared.button()
        UINavigationBar.appearance().barTintColor = AppearanceService.shared.navigationBar()
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: AppearanceService.shared.button()]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppearanceService.shared.button()]
        UINavigationBar.appearance().isTranslucent = false
    }
}
