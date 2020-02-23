//
//  Date+Utils.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/23/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

extension Date {
    var beautyStyle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss MM-dd-yyyy"

        return dateFormatter.string(from: self)
    }
}
