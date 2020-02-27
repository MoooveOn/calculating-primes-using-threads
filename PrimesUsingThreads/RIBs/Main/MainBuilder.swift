//
//  MainBuilder.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol MainDependency: MainDependencyDetails {
    var serviceBuilder: ServiceBuildable { get }
}

final class MainComponent: Component<MainDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol MainBuildable: Buildable {
    func build(withListener listener: MainListener) -> MainRouting
}

final class MainBuilder: Builder<MainDependency>, MainBuildable {

    override init(dependency: MainDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MainListener) -> MainRouting {
        let component = MainComponent(dependency: dependency)
        let viewController = MainViewController()
        let interactor = MainInteractor(presenter: viewController,
                                        calculatingPrimesService: dependency.serviceBuilder.calculatingPrimesService,
                                        coreDataService: dependency.serviceBuilder.coreDataService)
        interactor.listener = listener

        let detailsBuilder = DetailsBuilder(dependency: component)

        return MainRouter(interactor: interactor,
                          viewController: viewController,
                          detailsBuilder: detailsBuilder)
    }
}
