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
    func calculatePrimesUsingThreadPoolUp(to limit: Int64, threadsCount: Int, cachedPrimes: [Int64])
}

final class CalculatingPrimesService: CalculatingPrimesServicing {
    private var delegates: [CalculatingPrimesDelagate] = []
    private var threadPool: ThreadPool!
    private var isBusy: Bool = false
    private var chunksCount: Int64 = 0 {
        didSet {
            remainingTasks = chunksCount
        }
    }

    private let dataLocker = NSLock()

    private var remainingTasks: Int64 = 0
    private var calculatedPrimes: [Int64] = []

    private var startCalculationTime: UInt64!
    private var finishCalculationTime: UInt64!

    private var upperBound: Int64 = 2
    private var threadsCount: Int = 0

    @UserDefaultsStorable(key: "maxCachedUpperBound", defaultValue: 2)
    private var maxCachedUpperBound: Int64

    private var progressValue: Double = 0.0 {
        didSet { delegates.forEach { $0.didCompleteSubtask(portionSize: progressValue) } }
    }

    init() { }

    // MARK: - CalculatingPrimesServicing

    func addListener(_ delegate: CalculatingPrimesDelagate) {
        delegates.append(delegate)
    }

    func calculatePrimesUsingThreadPoolUp(to limit: Int64, threadsCount: Int, cachedPrimes: [Int64]) {
        startCalculationTime = DispatchTime.now().uptimeNanoseconds
        upperBound = limit

        guard
          !isBusy,
          !isTooSmall(),
          !hasCalculated(cachedPrimes: cachedPrimes)
          else {
            return
        }

        isBusy = true

        var startNumber: Int64 = 2
        if !cachedPrimes.isEmpty {
            startNumber = maxCachedUpperBound
            add(cachedPrimes: cachedPrimes)
        }

        let newTask = prepareNewTask(startNumber: startNumber, threadsCount: threadsCount)
        DispatchQueue.global(qos: .userInitiated).async {
            newTask()
        }
    }

    private func isTooSmall() -> Bool {
        guard upperBound <= 2 else { return false }

        notifyDelegatesOfCompletion()

        return true
    }

    private func hasCalculated(cachedPrimes: [Int64]) -> Bool {
        guard
          !cachedPrimes.isEmpty,
          maxCachedUpperBound >= upperBound
          else {
            return false
        }

        let upperIndex: Int = cachedPrimes.firstIndex { $0 >= upperBound } ?? cachedPrimes.count
        calculatedPrimes = Array(cachedPrimes.prefix(upTo: upperIndex))
        notifyDelegatesOfCompletion()

        return true
    }

    private func add(cachedPrimes: [Int64]) {
        dataLocker.lock()
        calculatedPrimes.append(contentsOf: cachedPrimes)
        dataLocker.unlock()
    }

    private func prepareNewTask(startNumber: Int64, threadsCount: Int) -> () -> () {
        let task = { [weak self] in
            guard let self = self else { return }

            self.threadsCount = threadsCount

            var chunkSize: Int64 = 128;
            self.chunksCount = (self.upperBound - startNumber) / chunkSize;

            while(self.chunksCount < self.threadsCount && chunkSize > 1) {
                chunkSize /= 2
                self.chunksCount = (self.upperBound - startNumber) / chunkSize;
            }

            if self.chunksCount < threadsCount {
                self.threadsCount = Int(self.chunksCount)
            }

            self.threadPool = ThreadPool(threadsCount: self.threadsCount, threadPriority: 1.0)
            for i in 0..<self.chunksCount {
                let chunkStart = startNumber + i * chunkSize;
                let chunkEnd = i == (self.chunksCount - 1) ? self.upperBound : chunkStart + chunkSize;
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
        progressValue += 1.0 / Double(chunksCount)
        checkCompletion()
        dataLocker.unlock()
    }

    private func checkCompletion() {
        guard remainingTasks == 0 else { return }

        if upperBound > maxCachedUpperBound {
            maxCachedUpperBound = upperBound
        }
        notifyDelegatesOfCompletion()
    }

    private func notifyDelegatesOfCompletion() {
        finishCalculationTime = DispatchTime.now().uptimeNanoseconds

        let elapsedTime = Double((finishCalculationTime - startCalculationTime)) / 1_000_000_000.0
        let result = MainPreviewModel(startTime: Date(),
                                      upperBound: upperBound,
                                      threadsCount: threadsCount,
                                      elapsedTime: elapsedTime)
        delegates.forEach {
            $0.taskCompleted(result: result, primes: calculatedPrimes)
        }

        resetState()
    }

    private func resetState() {
        startCalculationTime = nil
        finishCalculationTime = nil
        chunksCount = 0
        upperBound = 0
        threadsCount = 0
        threadPool = nil
        isBusy = false
        progressValue = 0.0
        calculatedPrimes.removeAll()
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
