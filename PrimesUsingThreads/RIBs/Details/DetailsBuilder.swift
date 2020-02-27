//
//  DetailsBuilder.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/27/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol DetailsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DetailsComponent: Component<DetailsDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DetailsBuildable: Buildable {
    func build(withListener listener: DetailsListener) -> DetailsRouting
}

final class DetailsBuilder: Builder<DetailsDependency>, DetailsBuildable {

    override init(dependency: DetailsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailsListener) -> DetailsRouting {
        let component = DetailsComponent(dependency: dependency)
        let viewController = DetailsViewController()
        let interactor = DetailsInteractor(presenter: viewController)
        interactor.listener = listener
        return DetailsRouter(interactor: interactor, viewController: viewController)
    }
}
