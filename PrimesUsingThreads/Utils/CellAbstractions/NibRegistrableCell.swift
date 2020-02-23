//
//  NibRegistrableCell.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/23/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit.UITableView

protocol NibRegistrableCell: ReusableCell {
    static var nibName: String { get }
}

extension NibRegistrableCell {
    static var nibName: String {
        return reuseIdentifier
    }
}

extension UITableView {
    final func registerReusableCell(cell: NibRegistrableCell.Type) {
        let nib = UINib(nibName: cell.nibName, bundle: .main)
        register(nib, forCellReuseIdentifier: cell.reuseIdentifier)
    }
}
