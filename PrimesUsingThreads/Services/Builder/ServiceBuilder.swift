//
//  ServiceBuilder.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs

protocol ServiceDependency: Dependency {

}

protocol ServiceBuildable {
    var calculatingPrimesService: CalculatingPrimesServicing { get }
}

final class ServiceBuilder: Builder<ServiceDependency>, ServiceBuildable {

    // MARK: - CalculatingPrimesService

    var calculatingPrimesService: CalculatingPrimesServicing = CalculatingPrimesService()

    // MARK: - CoreData Manager

}
