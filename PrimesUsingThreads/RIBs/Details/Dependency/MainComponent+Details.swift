//
//  MainComponent+Details.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/27/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

/// The dependencies needed from the parent scope of Main to provide for the Details scope.
protocol MainDependencyDetails: Dependency {
    // TODO: Declare dependencies needed from the parent scope of Main to provide dependencies
    // for the Details scope.
}

extension MainComponent: DetailsDependency {

    // TODO: Implement properties to provide for Details scope.
}
