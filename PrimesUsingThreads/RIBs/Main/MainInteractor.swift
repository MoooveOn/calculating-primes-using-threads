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
    func routeToDetails(with previewModel: MainPreviewModel, primes: [Int64])
    func routeFromDetails()
}

protocol MainPresentable: Presentable {
    var listener: MainPresentableListener? { get set }
    var inProgress: Bool { get set }

    func progressView(isEnable: Bool)
    func setProgressView(to: Double)
    func insertRow(at indexPath: IndexPath)
    func cleanCacheFinished()
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

        loadCoreData()
    }

    override func willResignActive() {
        super.willResignActive()
    }

    private func loadCoreData() {
        coreDataService.fetchRecords { [weak self] records in
            self?.cacheRecords = records
        }
    }
}

// MARK: - MainPresentableListener

extension MainInteractor: MainPresentableListener {
    var cacheRecordsCount: Int { cacheRecords.count }

    func cacheRecord(at index: Int) -> MainPreviewModel { cacheRecords[index] }

    func onDetailsAction(index: Int) {
        let record = cacheRecord(at: index)
        let primes = coreDataService.getPrimes(upTo: record.upperBound)
        router?.routeToDetails(with: record, primes: primes)
    }

    func onStartButtonAction(upperBound: Int, threadCount: Int) {
        calculatingPrimesService.calculatePrimesUsingThreadPoolUp(to: Int64(upperBound), threadCount: threadCount, cachedPrimes: coreDataService.cachedPrimes)
        presenter.progressView(isEnable: true)
    }

    func onCleanCacheButtonAction() {
        coreDataService.cleanCache()
        cacheRecords.removeAll()
        presenter.cleanCacheFinished()
    }
}

// MARK: - CalculatingPrimesDelagate

extension MainInteractor: CalculatingPrimesDelagate {
    func didCompleteSubtask(portionSize: Double) {
        presenter.setProgressView(to: portionSize)
    }

    func taskCompleted(result: MainPreviewModel, primes: [Int64]) {
        coreDataService.save(record: result, primes: primes)
        cacheRecords.insert(result, at: 0)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.presenter.insertRow(at: IndexPath(row: 0, section: 0))
            self.presenter.progressView(isEnable: false)
            self.presenter.inProgress = false
        }
    }
}

// MARK: - DetailsListener

extension MainInteractor: DetailsListener {
    func closeDetails() {
        router?.routeFromDetails()
    }
}
