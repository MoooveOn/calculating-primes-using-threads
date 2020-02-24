//
//  CalculatingPrimesService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/24/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

protocol CalculatingPrimesDelagate {
    func taskCompleted(result: MainPreviewModel)
}

protocol CalculatingPrimesServicing {
    func addListener(_ delegate: CalculatingPrimesDelagate)
    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int)
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

    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int) {
        guard !isBusy else { return }
        isBusy = true

        threadPool = ThreadPool(threadCount: threadCount, threadPriority: 10.0)

        let chunkSize: Int = 100;
        chunks = (limit - 2) / chunkSize;

        for i in 0..<chunks {
            let chunkStart = 2 + i * chunkSize;
            let chunkEnd = i == (chunks - 1) ? limit : chunkStart + chunkSize;
            threadPool.addTask(ThreadPoolTask({ _ in
                var portion: [Int] = []
                for number in chunkStart..<chunkEnd {
                    if isPrime(number: number) {
                        portion.append(number)
                    }
                }
                self.addData(portion)
            }))
        }
    }

    private let dataLocker = NSLock()

    private var remainingTasks: Int = 0
    private var primes: [Int] = []

    private var start: UInt64?
    private var end: UInt64?

    private func addData(_ portion: [Int]) {
        dataLocker.lock()
        primes.append(contentsOf: portion)

        remainingTasks -= 1

        if remainingTasks == 0 {
            print(primes.sorted())
            print(primes.count)

            end = DispatchTime.now().uptimeNanoseconds
            let elapsedTime = Double((end! - start!)) / 1_000_000_000.0
            DispatchQueue.main.async {
                print("Threads: \(elapsedTime) sec")
            }

            let result = MainPreviewModel(startTime: Date(),
                                          upperBound: 10,
                                          threadsCount: 10,
                                          elapsedTime: elapsedTime)
            delegates.forEach {
                $0.taskCompleted(result: result)
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
