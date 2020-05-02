//
//  ReusableSupplementaryView.swift
//  AiForFit
//
//  Created by Pavel Selivanov on 3/12/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

protocol ReusableSupplementaryView {
    static var reuseIdentifier: String { get }
}

extension ReusableSupplementaryView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
