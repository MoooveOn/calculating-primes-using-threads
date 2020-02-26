//
//  PrimesCalculating+CoreDataProperties.swift
//  
//
//  Created by Pavel Selivanov on 2/25/20.
//
//

import Foundation
import CoreData


extension PrimesCalculating {
    static let entityName: String = String(describing: PrimesCalculating.self)

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<PrimesCalculating> {
        return NSFetchRequest<PrimesCalculating>(entityName: PrimesCalculating.entityName)
    }

    @NSManaged public var elapsedTime: Double
    @NSManaged public var startTime: Date?
    @NSManaged public var threadsCount: Int16
    @NSManaged public var upperBound: Int64
}
