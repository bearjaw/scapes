//
//  AppAppearanceProtocol.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

protocol AppAppearanceProtocol {
    func navigationBar() -> UIColor
    func navigationBarTint() -> UIColor
    func tabBar() -> UIColor
    func tabBarTint() -> UIColor
    func view() -> UIColor
    func button() -> UIColor
    func textBody() -> UIColor
    func textSubHeadline() -> UIColor
    func textHeadline() -> UIColor
    func textTitle() -> UIColor
    func textLink() -> UIColor
    func textButton() -> UIColor
}
