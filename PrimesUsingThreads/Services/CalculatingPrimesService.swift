//
//  CalculatingPrimesService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/24/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

protocol CalculatingPrimesDelagate {
    func taskCompleted(result: MainPreviewModel, primes: [Int64])
}

protocol CalculatingPrimesServicing {
    func addListener(_ delegate: CalculatingPrimesDelagate)
    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int, cachedPrimes: [Int64])
}

final class CalculatingPrimesService: CalculatingPrimesServicing {
    private var delegates: [CalculatingPrimesDelagate] = []
    private var threadPool: ThreadPool!
    private var isBusy: Bool = false

    init() { }

    func addListener(_ delegate: CalculatingPrimesDelagate) {
        delegates.append(delegate)
    }

    var chunks: Int = 0 {
        didSet {
            remainingTasks = chunks
        }
    }

    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int, cachedPrimes: [Int64]) {
        guard !isBusy else { return }
        isBusy = true

        let newTask = prepareNewTask(to: limit, threadCount: threadCount)
        DispatchQueue.global(qos: .userInitiated).async {
            newTask()
        }
    }

    private func prepareNewTask(start: Int = 2, to limit: Int, threadCount: Int) -> () -> () {
        let task = { [weak self] in
            guard let self = self else { return }

            self.threadPool = ThreadPool(threadCount: threadCount, threadPriority: 10.0)

            let chunkSize: Int = 100;
            self.chunks = (limit - start) / chunkSize;
            self.upperBound = Int64(limit)
            self.threadsCount = Int16(threadCount)

            for i in 0..<self.chunks {
                let chunkStart = start + i * chunkSize;
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

    private let dataLocker = NSLock()

    private var remainingTasks: Int = 0
    private var primes: [Int64] = []

    private var start: UInt64?
    private var end: UInt64?

    private var upperBound: Int64 = 2
    private var threadsCount: Int16 = 1

    private func addData(_ portion: [Int64]) {
        dataLocker.lock()
        primes.append(contentsOf: portion)

        remainingTasks -= 1

        if remainingTasks == 0 {
            print(primes.sorted())
            print(primes.count)

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

        } else if remainingTasks == chunks - 1 {
            start = DispatchTime.now().uptimeNanoseconds
        }

        dataLocker.unlock()
    }
}

fileprivate func isPrime(number: Int) -> Bool {
    if (number == 2) {
        return true
    } else if (number % 2 == 0) {
        return false
    }

    let upperBound: Int = number / 2
    var divisor: Int = 3
    while (divisor < upperBound) {
        if (number % divisor == 0) {
            return false
        }

        divisor += 2
    }

    return true
}
