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
    private var calculatedPrimes: [Int64] = []

    private var startTime: UInt64!
    private var finishTime: UInt64!

    private var upperBound: Int64 = 2
    private var threadsCount: Int = 1

    @UserDefaultsStorable(key: "maxCachedUpperBound", defaultValue: 2)
    private var maxCachedUpperBound: Int64

    private var progressValue: Double = 0.0 {
        didSet { delegates.forEach { $0.didCompleteSubtask(portionSize: progressValue) } }
    }

    init() { }

    func addListener(_ delegate: CalculatingPrimesDelagate) {
        delegates.append(delegate)
    }

    private func hasCalculated(limit: Int64, cachedPrimes: [Int64]) -> Bool {
        guard !cachedPrimes.isEmpty else { return false }

        if maxCachedUpperBound >= limit {
            let upperIndex: Int = cachedPrimes.firstIndex { $0 >= limit } ?? cachedPrimes.count
            let primes: [Int64] = Array(cachedPrimes.prefix(upTo: upperIndex))
            finishTime = DispatchTime.now().uptimeNanoseconds
            let elapsedTime = Double((finishTime - startTime)) / 1_000_000_000.0
            let result = MainPreviewModel(startTime: Date(),
                                          upperBound: limit,
                                          threadsCount: 0,
                                          elapsedTime: elapsedTime)
            delegates.forEach {
                $0.taskCompleted(result: result, primes: primes)
            }
            resetState()
            
            return true
        }

        return false
    }

    func calculatePrimesUsingThreadPoolUp(to limit: Int64, threadCount: Int, cachedPrimes: [Int64]) {
        startTime = DispatchTime.now().uptimeNanoseconds

        guard
          !isBusy,
          !hasCalculated(limit: limit, cachedPrimes: cachedPrimes)
          else {
            return
        }

        isBusy = true

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
        calculatedPrimes.append(contentsOf: cachedPrimes)
        dataLocker.unlock()
    }

    private func prepareNewTask(startNumber: Int64, to limit: Int64, threadCount: Int) -> () -> () {
        let task = { [weak self] in
            guard let self = self else { return }

            self.upperBound = Int64(limit)

            self.threadsCount = threadCount
            self.threadPool = ThreadPool(threadCount: threadCount, threadPriority: 1.0)

            let chunkSize: Int64 = 100;
            self.chunks = (limit - startNumber) / chunkSize;

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
        calculatedPrimes.append(contentsOf: portion)
        remainingTasks -= 1
        progressValue += 1.0 / Double(chunks)
        checkCompletion()
        dataLocker.unlock()
    }

    private func checkCompletion() {
        guard remainingTasks == 0 else { return }

        finishTime = DispatchTime.now().uptimeNanoseconds

        let elapsedTime = Double((finishTime - startTime)) / 1_000_000_000.0
        let result = MainPreviewModel(startTime: Date(),
                                      upperBound: upperBound,
                                      threadsCount: threadsCount,
                                      elapsedTime: elapsedTime)
        delegates.forEach {
            $0.taskCompleted(result: result, primes: calculatedPrimes)
        }

        if upperBound > maxCachedUpperBound {
            maxCachedUpperBound = upperBound
        }

        resetState()
    }

    private func resetState() {
        calculatedPrimes.removeAll()
        startTime = nil
        finishTime = nil
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
