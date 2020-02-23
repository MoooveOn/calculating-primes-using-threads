//
//  RootRouter.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol RootInteractable: Interactable, MainListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

    // MARK: - Private

    private var main: ViewableRouting?
    private let mainBuilder: MainBuildable
    
    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         mainBuilder: MainBuildable) {

        self.mainBuilder = mainBuilder

        super.init(interactor: interactor, viewController: viewController)

        interactor.router = self
    }

    // MARK: - interface

    func routeToMain() {
        let rib = mainBuilder.build(withListener: interactor)
        main = presentRIB(rib)
    }
}
