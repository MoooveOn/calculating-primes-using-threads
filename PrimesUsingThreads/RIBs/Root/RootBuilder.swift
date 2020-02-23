//
//  RootBuilder.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol RootDependency: RootDependencyMain {
    var serviceBuilder: ServiceBuildable { get }
}

final class RootComponent: Component<RootDependency> {

    let rootViewController: RootViewController

    init(dependency: RootDependency,
         rootViewController: RootViewController) {

        self.rootViewController = rootViewController

        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency> {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }
}

extension RootBuilder: RootBuildable {
    func build() -> LaunchRouting  {
        let viewController = RootViewController()
        let component      = RootComponent(dependency: dependency,
                                           rootViewController: viewController)
        let interactor     = RootInteractor(presenter: viewController)

        let mainBuilder = MainBuilder(dependency: component)

        let router = RootRouter(interactor: interactor,
                                viewController: viewController,
                                mainBuilder: mainBuilder)

        return router
    }
}
