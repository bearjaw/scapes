//
//  UIColor+Extension.swift
//  Scapes
//
//  Created by Max Baumbach on 07/07/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Base palette
    
    static var primary: UIColor {
        return UIColor(named: "primaryDark")!
    }
    
    static var secondary: UIColor {
        return UIColor(named: "primaryLight")!
    }
    
    static var action: UIColor {
        return UIColor(named: "mustard")!
    }
    
    // MARK: - Label
    
    static var link: UIColor {
        return UIColor(named: "secondaryLight")!
    }
    
    static var subtitle: UIColor {
        return .action
    }
    
    static var text: UIColor {
        return UIColor(named: "textRegular")!
    }
    
    static var title: UIColor {
        return UIColor(named: "textRegular")!
    }
    
    // MARK: - Button
    
    static var button: UIColor {
        return .action
    }
    
    // MARK: - Status
    
    static var error: UIColor {
        return UIColor(named: "error")!
    }
    
    static var warning: UIColor {
        return UIColor(named: "warning")!
    }
    
    // MARK: Navbar
    
    static var barTint: UIColor {
        return .primary
    }
    
    static var tintColor: UIColor {
        return  .action
    }
}
