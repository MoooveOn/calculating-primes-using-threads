//
//  CoreDataService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/25/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import CoreData

protocol CoreDataServicing {
    func fetchRecords() -> [MainPreviewModel]
    func save(record: MainPreviewModel, newPrimes: [Int64])
    func cleanCache()
}

final class CoreDataService: CoreDataServicing {
    private let coreDataStack: CoreDataStack = CoreDataStack.shared

    func fetchRecords() -> [MainPreviewModel] {
        let fetchRequest = PrimesCalculating.createFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "upperBound", ascending: true)]
        var result: [PrimesCalculating] = []
        do {
            let context = coreDataStack.viewContext
            result = try context.fetch(fetchRequest)
        } catch {
            print("Error occurred: \(error.localizedDescription)")
        }

        return result.compactMap { (item: PrimesCalculating) -> MainPreviewModel? in
            return MainPreviewModel(startTime: item.startTime ?? Date(),
                                    upperBound: item.upperBound,
                                    threadsCount: item.threadsCount,
                                    elapsedTime: item.elapsedTime)
        }
    }

     func save(record: MainPreviewModel, newPrimes: [Int64]) {
        guard coreDataStack.viewContext.hasChanges else { return }

        do {
            try coreDataStack.viewContext.save()
        } catch let error as NSError {
            print("Unresolved error during saving managed object context: \(error), \(error.userInfo)")
        }
    }

    func cleanCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PrimesCalculating.entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            let context = coreDataStack.viewContext
            try context.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Error occurred: \(error.localizedDescription)")
        }
    }
}
