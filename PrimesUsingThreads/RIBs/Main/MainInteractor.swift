//
//  MainInteractor.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs
import RxSwift

protocol MainRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol MainPresentable: Presentable {
    var listener: MainPresentableListener? { get set }
    var inProgress: Bool { get set }

    func cleanCacheFinished()
    func insertRow(at indexPath: IndexPath)
}

protocol MainListener: class {

}

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable {

    weak var router: MainRouting?
    weak var listener: MainListener?
    private var calculatingPrimesService: CalculatingPrimesServicing

    var cacheRecords: [MainPreviewModel] = [
            MainPreviewModel(startTime: Date().addingTimeInterval(60), upperBound: 10, threadsCount: 10, elapsedTime: 12.678),
            MainPreviewModel(startTime: Date().addingTimeInterval(600), upperBound: 10, threadsCount: 7, elapsedTime: 0.678),
            MainPreviewModel(startTime: Date(), upperBound: 100000, threadsCount: 9, elapsedTime: 3.678),
            MainPreviewModel(startTime: Date().addingTimeInterval(120), upperBound: 3, threadsCount: 8, elapsedTime: 10.678),
            MainPreviewModel(startTime: Date().addingTimeInterval(30), upperBound: 2, threadsCount: 7, elapsedTime: 7.678)
    ]

    init(presenter: MainPresentable,
         calculatingPrimesService: CalculatingPrimesServicing) {
        
        self.calculatingPrimesService = calculatingPrimesService

        super.init(presenter: presenter)

        presenter.listener = self
        calculatingPrimesService.addListener(self)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

// MARK: - MainPresentableListener

extension MainInteractor: MainPresentableListener {
    func onStartButtonAction(upperBound: Int, threadsCount: Int) {
        calculatingPrimesService.calculatePrimesUsingThreadPoolUp(to: upperBound, threadCount: threadsCount)
    }

    func onCleanCacheButtonAction() {
        // clean CoreData
        presenter.cleanCacheFinished()
    }
}

// MARK: - CalculatingPrimesDelagate

extension MainInteractor: CalculatingPrimesDelagate {
    func taskCompleted(result: MainPreviewModel) {
        // when finished - save & update table
        cacheRecords.append(result)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.presenter.insertRow(at: IndexPath(row: self.cacheRecords.count - 1, section: 0))
            self.presenter.inProgress = false
        }
    }
}
