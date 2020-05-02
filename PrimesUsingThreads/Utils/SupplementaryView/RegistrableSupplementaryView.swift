//
//  RegistrableSupplementaryView.swift
//  AiForFit
//
//  Created by Pavel Selivanov on 3/12/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit.UICollectionView

protocol NibRegistrableSupplementaryView: ReusableSupplementaryView {
    static var nibName: String { get }
}

extension NibRegistrableSupplementaryView {
    static var nibName: String { reuseIdentifier }
}

enum SupplementaryViewKind: String {
    case header
    case footer

    var value: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UICollectionView {
    final func registerReusableSupplementary(view: NibRegistrableSupplementaryView.Type, for kind: SupplementaryViewKind) {
        let nib = UINib(nibName: view.nibName, bundle: .main)
        register(nib, forSupplementaryViewOfKind: kind.value, withReuseIdentifier: view.reuseIdentifier)
    }
}

extension UITableView {
    final func registerReusableSupplementary(view: NibRegistrableSupplementaryView.Type) {
        let nib = UINib(nibName: view.nibName, bundle: .main)
        register(nib, forHeaderFooterViewReuseIdentifier: view.reuseIdentifier)
    }
}
