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

    func minutesAndSeconds(from date: Date) -> String {
        let elapsedTime: TimeInterval = Double(self.timeIntervalSince1970 - date.timeIntervalSince1970)
        let seconds: Int = Int(elapsedTime.remainder(dividingBy: TimeInterval.minute))
        let minutes: Int = Int(elapsedTime / TimeInterval.minute)
        return String(format: "%d min: %d sec", minutes, seconds)
    }
}
