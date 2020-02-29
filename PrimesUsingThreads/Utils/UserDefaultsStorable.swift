//
//  File.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/28/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsStorable<Value> {
    let key: String
    let defaultValue: Value
    private let storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
