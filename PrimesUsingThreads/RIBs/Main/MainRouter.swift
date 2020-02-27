//
//  MainRouter.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol MainInteractable: Interactable, DetailsListener {
    var router: MainRouting? { get set }
    var listener: MainListener? { get set }
}

protocol MainViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MainRouter: ViewableRouter<MainInteractable, MainViewControllable>, MainRouting {
    init(interactor: MainInteractable,
         viewController: MainViewControllable,
         detailsBuilder: DetailsBuildable) {

        self.detailsBuilder = detailsBuilder

        super.init(interactor: interactor, viewController: viewController)

        interactor.router = self
    }

    // MARK: - Private

    private var details: ViewableRouting?
    private let detailsBuilder: DetailsBuildable

    func routeToDetails(with previewModel: MainPreviewModel, primes: [Int64]) {
        let rib = detailsBuilder.build(withListener: interactor, previewModel: previewModel, primes: primes)
        details = presentRIB(rib)
    }

    func routeFromDetails() {
        dismissRIB(&details)
    }
}
