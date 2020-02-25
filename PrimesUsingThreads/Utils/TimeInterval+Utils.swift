//
//  TimeInterval+Utils.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/25/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let day: TimeInterval    = 60 * 60 * 24
    static let week: TimeInterval   = day * 7
    static let year: TimeInterval   = day * 365
}
