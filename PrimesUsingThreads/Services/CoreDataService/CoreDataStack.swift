//
//  CoreDataStack.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/25/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import CoreData

final class CoreDataStack {
    static let shared: CoreDataStack = CoreDataStack()

    private init() {
        print("init CoreDataStack")
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Primes")

        container.loadPersistentStores { persistentStoreDescription, error in
            guard let error = error as NSError? else { return }
            fatalError(#"Unresolved error: \#(error), \#(error.description)"#)
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    deinit {
        print("deinit CoreDataStack")
    }
}
