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
    func save(record: MainPreviewModel, primes: [Int64])
    func cleanCache()
}

final class CoreDataService: CoreDataServicing {
    private let coreDataStack: CoreDataStack = CoreDataStack.shared

    func fetchRecords() -> [MainPreviewModel] {
        let fetchRequest = PrimesCalculating.createFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
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

     func save(record: MainPreviewModel, primes: [Int64]) {
        let savingTask = { [weak self] in
            guard let self = self else { return }

            let newItem = PrimesCalculating(context: self.coreDataStack.viewContext)
            newItem.startTime = record.startTime
            newItem.upperBound = record.upperBound
            newItem.threadsCount = record.threadsCount
            newItem.elapsedTime = record.elapsedTime

            do {
                try self.coreDataStack.viewContext.save()
            } catch let error as NSError {
                print("Unresolved error during saving managed object context: \(error), \(error.userInfo)")
            }
        }

        DispatchQueue.main.async {
            savingTask()
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
