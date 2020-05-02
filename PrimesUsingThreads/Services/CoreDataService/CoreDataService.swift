//
//  CoreDataService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/25/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import CoreData

protocol CoreDataServicing {
    var cachedPrimes: [Int64] { get }
    
    func addListener(_ delegate: CoreDataDelegate)
    func fetchRecords(completion: @escaping (_ records: [MainPreviewModel]) -> ())
    func getPrimes(upTo upperBound: Int64) -> [Int64]
    func save(record: MainPreviewModel, primes: [Int64])
    func cleanCache()
}

protocol CoreDataDelegate {

}

final class CoreDataService: CoreDataServicing {
    private var delegates: [CoreDataDelegate] = []
    private let coreDataStack: CoreDataStack = CoreDataStack.shared
    internal var cachedPrimes: [Int64] = []
    
    @UserDefaultsStorable(key: "maxCachedUpperBound", defaultValue: 2)
    private var maxCachedUpperBound: Int64

    init() {
        fetchPrimes()
    }

    func addListener(_ delegate: CoreDataDelegate) {
        delegates.append(delegate)
    }

    func fetchRecords(completion: @escaping (_ records: [MainPreviewModel]) -> ()) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let fetchRequest = PrimesCalculating.createFetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
            var result: [PrimesCalculating] = []
            do {
                result = try context.fetch(fetchRequest)
            } catch let error {
                print("Error occurred: \(error.localizedDescription)")
            }

            let records: [MainPreviewModel] = result.compactMap { (item: PrimesCalculating) -> MainPreviewModel? in
                MainPreviewModel(startTime: item.startTime ?? Date(),
                                 upperBound: item.upperBound,
                                 threadsCount: Int(item.threadsCount),
                                 elapsedTime: item.elapsedTime)
            }

            completion(records)
        }
    }

    private func fetchPrimes() {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }

            let fetchRequest = Prime.createfetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
            var result: [Prime] = []
            do {
                result = try context.fetch(fetchRequest)
            } catch let error {
                print("Error occurred: \(error.localizedDescription)")
            }

            self.cachedPrimes = result.compactMap { return $0.value }
        }
    }

    func getPrimes(upTo upperBound: Int64) -> [Int64] {
        let upperIndex: Int = cachedPrimes.firstIndex { $0 >= upperBound } ?? cachedPrimes.count
        return Array(cachedPrimes.prefix(upTo: upperIndex))
    }

    func save(record: MainPreviewModel, primes: [Int64]) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let newRecord = PrimesCalculating(context: context)
            newRecord.startTime = record.startTime
            newRecord.upperBound = record.upperBound
            newRecord.threadsCount = Int16(record.threadsCount)
            newRecord.elapsedTime = record.elapsedTime

            do {
                try context.save()
            } catch let error as NSError {
                print("Unresolved error during saving managed object context: \(error), \(error.userInfo)")
            }
        }

        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }

            let maxPrime: Int64 = self.cachedPrimes.last ?? 1
            for prime in primes {
                if prime > maxPrime {
                    let newItem = Prime(context: context)
                    newItem.value = prime
                    self.cachedPrimes.append(prime)
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
        let recordsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PrimesCalculating.entityName)
        let deleteRecordsRequest = NSBatchDeleteRequest(fetchRequest: recordsFetchRequest)
        let primesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Prime.entityName)
        let deletePrimesRequest = NSBatchDeleteRequest(fetchRequest: primesFetchRequest)

        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }

            do {
                self.maxCachedUpperBound = 0
                self.cachedPrimes.removeAll()
                try context.execute(deleteRecordsRequest)
                try context.execute(deletePrimesRequest)
                try context.save()
            } catch let error as NSError {
                print("Error occurred: \(error.localizedDescription)")
            }
        }
    }
}
