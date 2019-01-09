//
//  Appearance.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

struct Appearance {
    let primaryDark: UIColor
    let primaryLight: UIColor
    let secondaryDark: UIColor
    let secondaryLight: UIColor
}

enum AppearanceStyle {
    case light
    case dark
}

class AppearanceService {
    
    static var shared = AppearanceService(style: .dark)
    
    private var appearance: Appearance?
    fileprivate var style: AppearanceStyle
    
    init(style: AppearanceStyle) {
        self.style = style
        setupAppearance(for: style)
    }
    
    private func setupAppearance(for style:AppearanceStyle) {
        switch style {
            
        case .light:
            let appearance = Appearance(
                primaryDark: #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1),
                primaryLight: #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1843137255, alpha: 1),
                secondaryDark: #colorLiteral(red: 0.3607843137, green: 0.3607843137, blue: 0.3333333333, alpha: 1),
                secondaryLight: #colorLiteral(red: 0.7764705882, green: 1, blue: 0.9568627451, alpha: 0.8399999738)
            )
            self.appearance = appearance
        case .dark:
            let appearance = Appearance(
                primaryDark: #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1),
                primaryLight: #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1843137255, alpha: 1),
                secondaryDark: #colorLiteral(red: 0.3607843137, green: 0.3607843137, blue: 0.3333333333, alpha: 1),
                secondaryLight: UIColor(named: "mustard")!
            )
            self.appearance = appearance
        }
    }
    
    final func updateAppearance(appearance: Appearance) {
        self.appearance = appearance
    }
    
    final func updateAppearanceStyle(_ style:AppearanceStyle) {
        self.style = style
    }
}


extension AppearanceService: AppAppearanceProtocol {

    func navigationBar() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.primaryDark
    }
    
    func navigationBarTint() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.secondaryLight
    }
    
    func tabBar() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.primaryDark
    }
    
    func tabBarTint() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.secondaryLight
    }
    
    func view() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.primaryLight
    }
    
    func button() -> UIColor {
        guard let color = UIColor(named: "mustard") else {
            fatalError("Color literal mismatch.")
        }
        return color
    }
    
    func textBody() -> UIColor {
        switch style {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }
    
    func textSubHeadline() -> UIColor {
        guard let appearance = appearance else {
            fatalError("Must providse a primary dark color")
        }
        return appearance.secondaryLight
    }
    
    func textHeadline() -> UIColor {
        return textBody()
    }
    
    func textTitle() -> UIColor {
        return textBody()
    }
    
    func textLink() -> UIColor {
        guard let color = UIColor(named: "secondaryLight") else {
            fatalError("Color literal mismatch.")
        }
        return color
    }
    
    func textButton() -> UIColor {
        guard let color = UIColor(named: "goldenGrey") else {
            fatalError("Color literal mismatch.")
        }
        return color
    }
}
