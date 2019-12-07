//
//  UITableView+Extensions.swift
//  Scapes
//
//  Created by Max Baumbach on 07/12/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

extension UITableView {
    
    func dequeuedCell<T: UITableViewCell>(forIdentifier identifier: String, atIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Eror> Could not dequeue cell for identifier \(identifier). Please make sure you registered the cell \(T.self) ")
        }
        return cell
    }
}
