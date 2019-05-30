//
//  LiveData.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class LiveData<Value>: NSObject {
    public var value: Value? {
        didSet {
            resolve(value: value)
        }
    }
    
    private var callbacks: [(Value?) -> Void] = []
    
    init(_ initialValue: Value? = nil) {
        value = initialValue
    }
    
    // observe
    public func observe(_ onChange: @escaping (Value?) -> Void) {
        callbacks.append(onChange)
        triggerCallbacksIfResolved()
    }
    
    public func call() {
        triggerCallbacksIfResolved()
    }
    
    private func resolve(value: Value?) {
        triggerCallbacksIfResolved()
    }
    
    private func triggerCallbacksIfResolved() {
        callbacks.forEach { callback in
            callback(value)
        }
    }
}
