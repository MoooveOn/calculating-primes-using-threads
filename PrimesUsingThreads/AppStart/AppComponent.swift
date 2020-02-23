//
//  AppComponent.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

class AppComponent: Component<EmptyDependency>, RootDependency {

    // MARK: - Private

    private let application: UIApplication
    private let launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    init(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.application = application
        self.launchOptions = launchOptions
        super.init(dependency: EmptyComponent())
    }

    lazy var serviceBuilder: ServiceBuildable = ServiceBuilder(dependency: self)

    func setup() {

    }
}

extension AppComponent: ServiceDependency {
}


