//
//  MainRouter.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol MainInteractable: Interactable {
    var router: MainRouting? { get set }
    var listener: MainListener? { get set }
}

protocol MainViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MainRouter: ViewableRouter<MainInteractable, MainViewControllable>, MainRouting {
    override init(interactor: MainInteractable, viewController: MainViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
