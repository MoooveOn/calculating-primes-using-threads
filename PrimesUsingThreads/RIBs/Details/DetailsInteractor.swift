//
//  DetailsInteractor.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/27/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs
import RxSwift

protocol DetailsRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DetailsPresentable: Presentable {
    var listener: DetailsPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DetailsListener: class {
    func closeDetails()
}

final class DetailsInteractor: PresentableInteractor<DetailsPresentable>, DetailsInteractable {

    weak var router: DetailsRouting?
    weak var listener: DetailsListener?

    private(set) var previewModel: MainPreviewModel
    private let primes: [Int64]

    init(presenter: DetailsPresentable,
         previewModel: MainPreviewModel,
         primes: [Int64]) {

        self.previewModel = previewModel
        self.primes = primes

        super.init(presenter: presenter)
        
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}

// MARK: - DetailsPresentableListener

extension DetailsInteractor: DetailsPresentableListener {
    func onDoneAction() {
        listener?.closeDetails()
    }
}
