//
//  RootComponent+Main.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

/// The dependencies needed from the parent scope of Root to provide for the Main scope.

protocol RootDependencyMain: Dependency {
    // TODO: Declare dependencies needed from the parent scope of Root to provide dependencies
    // for the Main scope.
}

extension RootComponent: MainDependency {
    var serviceBuilder: ServiceBuildable {
        return dependency.serviceBuilder
    }
}
