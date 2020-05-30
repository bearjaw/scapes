//
//  UIViewController+Extensions.swift
//  Scapes
//
//  Created by Max Baumbach on 07/12/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func configureNavbar() {
        guard let navigationController = self.navigationController else { return }
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
        navigationController.view.backgroundColor = .secondary
    }
    
}

