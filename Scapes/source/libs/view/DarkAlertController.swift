//
//  DarkAlertController.swift
//  Scapes
//
//  Created by Max Baumbach on 22/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class DarkAlertController: UIAlertController {}

extension DarkAlertController {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let labels: [UILabel] = self.view.allSubviews() as  [UILabel]
        labels.forEach({ $0.textColor = .white })
    }
}
