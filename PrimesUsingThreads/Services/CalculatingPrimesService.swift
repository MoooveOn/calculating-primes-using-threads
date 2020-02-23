//
//  CalculatingPrimesService.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/24/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import Foundation

protocol CalculatingPrimesDelagate {
    func taskCompleted(elapsedTime: Double)
}

protocol CalculatingPrimesServicing {
    func addListener(_ delegate: CalculatingPrimesDelagate)
    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int)
}

final class CalculatingPrimesService: CalculatingPrimesServicing {
    private var delegates: [CalculatingPrimesDelagate] = []
    private var threadPool: ThreadPool!

    init() {

    }

    func addListener(_ delegate: CalculatingPrimesDelagate) {
        delegates.append(delegate)
    }

    func calculatePrimesUsingThreadPoolUp(to limit: Int, threadCount: Int) {
        threadPool = ThreadPool(threadCount: threadCount, threadPriority: 10.0)

        let chunkSize: Int = 100;
        let chunks = (limit - 2) / chunkSize;

        for i in 0..<chunks {
            let chunkStart = 2 + i * chunkSize;
            let chunkEnd = i == (chunks - 1) ? limit : chunkStart + chunkSize;
            print("\(chunkStart)...\(chunkEnd)")
            threadPool.addTask(ThreadPoolTask({ _ in
                var arr: [Int] = []
                for number in chunkStart..<chunkEnd {
                    if self.isPrime(number: number) {
                        arr.append(number)
                    }
                }
                self.addData(arr)
                self.increase()
            }))
        }
       // allDone.WaitOne();
    }

    private func isPrime(number: Int) -> Bool {
        if (number == 2) {
            return true
        } else if (number % 2 == 0) {
            return false
        }

        var divisor: Int = 3
        while (divisor < (number / 2)) {
            if (number % divisor == 0) {
                return false
            }

            divisor += 2
        }

        return true
    }

    private let tasksCompletedCounterLocker = NSLock()
    private let dataLocker = NSLock()

    private var tasksCompletedCounter: Int = 0
    private var primes: [Int] = []

    private var start: UInt64?
    private var end: UInt64?

    private func addData(_ portion: [Int]) {
        dataLocker.lock()
        primes.append(contentsOf: portion)
        dataLocker.unlock()
    }

    private func increase() {
        tasksCompletedCounterLocker.lock()
        tasksCompletedCounter += 1

        if tasksCompletedCounter == 9999 {
            print(primes.sorted())
            print(primes.count)

            end = DispatchTime.now().uptimeNanoseconds
            let elapsedTime = Double((end! - start!)) / 1_000_000_000.0
            DispatchQueue.main.async {
                print("Threads: \(elapsedTime) sec")
            }

            delegates.forEach {
                $0.taskCompleted(elapsedTime: elapsedTime)
            }

        } else if tasksCompletedCounter == 1 {
            start = DispatchTime.now().uptimeNanoseconds
        }

        tasksCompletedCounterLocker.unlock()
    }
}
