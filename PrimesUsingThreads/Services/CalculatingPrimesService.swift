//
//  CalculatingPrimesService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/24/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

protocol CalculatingPrimesDelagate {
    func didCompleteSubtask(portionSize: Double)
    func taskCompleted(result: MainPreviewModel, primes: [Int64])
}

protocol CalculatingPrimesServicing {
    func addListener(_ delegate: CalculatingPrimesDelagate)
    func calculatePrimesUsingThreadPoolUp(to limit: Int64, threadCount: Int, cachedPrimes: [Int64])
}

final class CalculatingPrimesService: CalculatingPrimesServicing {
    private var delegates: [CalculatingPrimesDelagate] = []
    private var threadPool: ThreadPool!
    private var isBusy: Bool = false
    private var chunks: Int64 = 0 {
        didSet {
            remainingTasks = chunks
        }
    }

    private let dataLocker = NSLock()

    private var remainingTasks: Int64 = 0
    private var primes: [Int64] = []

    private var start: UInt64?
    private var end: UInt64?

    private var upperBound: Int64 = 2
    private var threadsCount: Int = 1

    private var progressValue: Double = 0.0 {
        didSet { delegates.forEach { $0.didCompleteSubtask(portionSize: progressValue) } }
    }

    init() { }

    func addListener(_ delegate: CalculatingPrimesDelagate) {
        delegates.append(delegate)
    }

    private func hasCalculated(limit: Int64, threadCount: Int, cachedPrimes: [Int64]) -> Bool {
        guard !cachedPrimes.isEmpty else { return false }

        // TODO: use upper bound from user defaults here
        let maxCached = cachedPrimes[cachedPrimes.count - 1]
        if maxCached >= limit {
            let result = MainPreviewModel(startTime: Date(),
                                          upperBound: upperBound,
                                          threadsCount: threadCount,
                                          elapsedTime: 0.0)
            delegates.forEach {
                $0.taskCompleted(result: result, primes: [])
            }

            return true
        }

        return false
    }

    func calculatePrimesUsingThreadPoolUp(to limit: Int64, threadCount: Int, cachedPrimes: [Int64]) {
        guard
          !isBusy,
          !hasCalculated(limit: limit, threadCount: threadCount, cachedPrimes: cachedPrimes)
          else {
            return
        }

        isBusy = true

        // TODO: fix this logic
        var start: Int64 = 1
        if !cachedPrimes.isEmpty {
            start = cachedPrimes[cachedPrimes.count - 1] + 1
            add(cachedPrimes: cachedPrimes)
        }

        let newTask = prepareNewTask(startNumber: start, to: limit, threadCount: threadCount)
        DispatchQueue.global(qos: .userInitiated).async {
            newTask()
        }
    }

    private func add(cachedPrimes: [Int64]) {
        dataLocker.lock()
        primes.append(contentsOf: cachedPrimes)
        dataLocker.unlock()
    }

    private func prepareNewTask(startNumber: Int64, to limit: Int64, threadCount: Int) -> () -> () {
        let task = { [weak self] in
            guard let self = self else { return }

            self.start = DispatchTime.now().uptimeNanoseconds
            self.threadPool = ThreadPool(threadCount: threadCount, threadPriority: 1.0)

            let chunkSize: Int64 = 100;
            self.chunks = (limit - startNumber) / chunkSize;
            self.upperBound = Int64(limit)
            self.threadsCount = threadCount

            for i in 0..<self.chunks {
                let chunkStart = startNumber + i * chunkSize;
                let chunkEnd = i == (self.chunks - 1) ? limit : chunkStart + chunkSize;
                self.threadPool.addTask(ThreadPoolTask({ _ in
                    var portion: [Int64] = []
                    for number in chunkStart..<chunkEnd {
                        if isPrime(number: number) {
                            portion.append(Int64(number))
                        }
                    }
                    self.addData(portion)
                }))
            }
        }

        return task
    }

    private func addData(_ portion: [Int64]) {
        dataLocker.lock()
        primes.append(contentsOf: portion)
        remainingTasks -= 1
        progressValue += 1.0 / Double(chunks)
        checkCompletion()
        dataLocker.unlock()
    }

    private func checkCompletion() {
        guard remainingTasks == 0 else { return }

        end = DispatchTime.now().uptimeNanoseconds

        let elapsedTime = Double((end! - start!)) / 1_000_000_000.0
        let result = MainPreviewModel(startTime: Date(),
                                      upperBound: upperBound,
                                      threadsCount: threadsCount,
                                      elapsedTime: elapsedTime)
        delegates.forEach {
            $0.taskCompleted(result: result, primes: primes)
        }

        primes.removeAll()
        start = nil
        end = nil
        isBusy = false
        progressValue = 0.0
    }
}

fileprivate func isPrime(number: Int64) -> Bool {
    if (number == 2) {
        return true
    } else if (number % 2 == 0) {
        return false
    }

    let upperBound: Int64 = number / 2
    var divisor: Int64 = 3
    while (divisor < upperBound) {
        if (number % divisor == 0) {
            return false
        }

        divisor += 2
    }

    return true
}
