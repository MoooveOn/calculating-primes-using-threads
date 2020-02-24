//
//  MainPreviewCell.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/23/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit.UITableViewCell

class MainPreviewCell: UITableViewCell, ConfigurableCell, NibRegistrableCell {
    typealias T = MainPreviewModel

    // MARK: - IBOutlets

    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var upperBoundLabel: UILabel!
    @IBOutlet private weak var threadsCountLabel: UILabel!
    @IBOutlet private weak var elapsedTimeLabel: UILabel!

    func configure(_ item: MainPreviewModel, at indexPath: IndexPath) {
        startTimeLabel.text = #"Start time: \#(item.startTime.beautyStyle)"#
        upperBoundLabel.text = #"Upper bound: \#(item.upperBound)"#
        threadsCountLabel.text = #"Threads count: \#(item.threadsCount)"#
        let roundedElapsedTime = round(item.elapsedTime * 1000) / 1000
        elapsedTimeLabel.text = #"Elapsed time: \#(roundedElapsedTime) sec"#
    }
}
