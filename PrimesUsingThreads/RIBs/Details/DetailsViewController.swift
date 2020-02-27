//
//  DetailsViewController.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/27/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

protocol DetailsPresentableListener: class {
    func onDoneAction()
}

final class DetailsViewController: UIViewController, DetailsPresentable, DetailsViewControllable {

    weak var listener: DetailsPresentableListener?
}

// MARK: - IBAction

extension DetailsViewController {
    @IBAction func doneTapped(_ sender: Any) {
        listener?.onDoneAction()
    }
}
