//
//  DataManager.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/28/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

class DataManager<T> {

    private(set) var items: [T] = []

    var itemsCount: Int {
        return items.count
    }

    func item(at index: Int) -> T? {
        return items.indices.contains(index) ? items[index] : nil
    }

    func add(item: T) {
        items.append(item)
    }

    func add(portion: [T]) {
        items.append(contentsOf: portion)
    }

    func remove(at index: Int) {
        items.remove(at: index)
    }
}
