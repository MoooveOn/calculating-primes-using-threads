//
//  DetailsPrimeCell.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/28/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit

class DetailsPrimeCell: UITableViewCell, ConfigurableCell, NibRegistrableCell {
    typealias T = Int64

    @IBOutlet weak var label: UILabel!

    func configure(_ item: Int64, at indexPath: IndexPath) {
        label.text = #"\#(item)"#
    }
}
