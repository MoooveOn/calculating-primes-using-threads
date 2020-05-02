//
//  ConfigurableSupplementaryView.swift
//  AiForFit
//
//  Created by Pavel Selivanov on 3/12/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation.NSIndexPath

protocol ConfigurableSupplementaryView: ReusableSupplementaryView {
    associatedtype ModelType

    func configure(_ item: ModelType, at section: Int)
}
