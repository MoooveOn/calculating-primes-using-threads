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
    private let coreDataService: CoreDataServicing

    var cacheRecords: [MainPreviewModel] = []

    init(presenter: MainPresentable,
         calculatingPrimesService: CalculatingPrimesServicing,
         coreDataService: CoreDataServicing) {
        
        self.calculatingPrimesService = calculatingPrimesService
        self.coreDataService = coreDataService

        super.init(presenter: presenter)

        presenter.listener = self
        calculatingPrimesService.addListener(self)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        cacheRecords = coreDataService.fetchRecords()
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
        coreDataService.cleanCache()
        cacheRecords.removeAll()
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
