//
//  RepoToken.swift
//  Scapes
//
//  Created by Max Baumbach on 04/03/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import Foundation
import RealmSwift

typealias Token = NotificationToken

final class RepoToken {
    private var token: Token
    
    init(_ token: Token) {
        self.token = token
    }
    
    func invalidate() {
        token.invalidate()
    }
}
