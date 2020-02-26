//
//  Prime+CoreDataProperties.swift
//  
//
//  Created by Pavel Selivanov on 2/26/20.
//
//

import Foundation
import CoreData


extension Prime {
    static let entityName: String = String(describing: Prime.self)

    @nonobjc public class func createfetchRequest() -> NSFetchRequest<Prime> {
        return NSFetchRequest<Prime>(entityName: Prime.entityName)
    }

    @NSManaged public var value: Int64

}
