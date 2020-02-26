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
    func fetchPrimes() -> [Int64]
    func save(record: MainPreviewModel, primes: [Int64])
    func cleanCache()
}

final class CoreDataService: CoreDataServicing {
    private let coreDataStack: CoreDataStack = CoreDataStack.shared
    private var maxPrime: Int64 = 0

    func fetchRecords() -> [MainPreviewModel] {
        let fetchRequest = PrimesCalculating.createFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        var result: [PrimesCalculating] = []
        do {
            let context = coreDataStack.viewContext
            result = try context.fetch(fetchRequest)
        } catch let error {
            print("Error occurred: \(error.localizedDescription)")
        }

        return result.compactMap { (item: PrimesCalculating) -> MainPreviewModel? in
            return MainPreviewModel(startTime: item.startTime ?? Date(),
                                    upperBound: item.upperBound,
                                    threadsCount: item.threadsCount,
                                    elapsedTime: item.elapsedTime)
        }
    }

    func fetchPrimes() -> [Int64] {
        let fetchRequest = Prime.createfetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
        var result: [Prime] = []
        do {
            let context = coreDataStack.viewContext
            result = try context.fetch(fetchRequest)
        } catch let error {
            print("Error occurred: \(error.localizedDescription)")
        }
        maxPrime = result.last?.value ?? 0

        return result.compactMap { return $0.value }
    }

    func save(record: MainPreviewModel, primes: [Int64]) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let newRecord = PrimesCalculating(context: context)
            newRecord.startTime = record.startTime
            newRecord.upperBound = record.upperBound
            newRecord.threadsCount = record.threadsCount
            newRecord.elapsedTime = record.elapsedTime

            do {
                try context.save()
            } catch let error as NSError {
                print("Unresolved error during saving managed object context: \(error), \(error.userInfo)")
            }
        }

        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }

            for prime in primes {
                if prime > self.maxPrime {
                    let newPrime = Prime(context: context)
                    newPrime.value = prime
                }
            }

            do {
                try context.save()
            } catch let error as NSError {
                print("Unresolved error during saving managed object context: \(error), \(error.userInfo)")
            }
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
