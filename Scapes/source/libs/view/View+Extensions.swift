//
//  ViewExtensions.swift
//  Scapes
//
//  Created by Max Baumbach on 22/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

extension UIView {
    
    var border: CGFloat { return 16 }
    
    class func allSubviews<T: UIView>(view: UIView) -> [T] {
        return view.subviews.flatMap { subView -> [T] in
            var result = allSubviews(view: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }
    
    func allSubviews<T: UIView>() -> [T] {
        return UIView.allSubviews(view: self) as [T]
    }
}

extension UIView {
    public var rightBottom: CGPoint {
        return CGPoint(x: frame.origin.x + bounds.size.width, y: frame.origin.y + bounds.size.height)
    }
}

struct Alert {
    let title: String
    let message: String
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
