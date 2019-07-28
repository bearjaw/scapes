//
//  NSObjectProtocol+Extensions.swift
//  Umzugshelfer
//
//  Created by Max Baumbach on 01/01/2019.
//  Copyright © 2019 Max Baumbach GmbH. All rights reserved.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    
    typealias Disposable = NSKeyValueObservation
    
    func observe<Value>(_ keyPath: KeyPath<Self, Value>,
                        onChange: @escaping (Value?) -> Void) -> Disposable? {
        return observe(keyPath, options: [.initial, .new]) { _, change in
            onChange(change.newValue)
        }
    }
    
    /// Binds a value to a target
    ///
    /// - Parameters:
    ///   - sourceKeyPath: the source value
    ///   - target: a target that the source value should be bound to
    ///   - targetKeyPath: the target's keypath
    /// - Returns: a disposable to control the lifetime of the binding
    func bind<Value, Target>(_ sourceKeyPath: KeyPath<Self, Value>,
                             to target: Target,
                             at targetKeyPath: ReferenceWritableKeyPath<Target, Value>)
        -> Disposable? {
            return observe(sourceKeyPath, onChange: { (value) in
                if let newValue = value {
                    return target[keyPath: targetKeyPath] = newValue
                }
            })
//            return observe(sourceKeyPath) { target[keyPath: targetKeyPath] = $0 }
    }
}
