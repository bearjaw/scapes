//
//  ViewExtensions.swift
//  Scapes
//
//  Created by Max Baumbach on 22/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

extension UIView {
    
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
    
    func rightBottom() -> CGPoint {
        return (CGPoint(x: frame.origin.x + bounds.size.width, y: frame.origin.y + bounds.size.height))
    }
}
