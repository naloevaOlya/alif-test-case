//
//  FirstTask.swift
//  alif-test-case
//
//  Created by Оля Налоева on 02.02.2025.
//

import Foundation

class FirstTask {
    func replacemenеtByZero(in array: [Int]) -> [Int] {
        array.compactMap { $0 > 0 ? $0 : 0 }
    }

    func sortByMax(in array: [Int]) -> [Int] {
        array.sorted(by: >)
    }

    func sortByMin(in array: [Int]) -> [Int] {
        array.sorted(by: <)
    }

    func findMax(in array: [Int]) -> Int? {
        array.max()
    }

    func findMin(in array: [Int]) -> Int? {
        array.min()
    }

    func sum(of array: [Int]) -> Int {
        array.reduce(0, +)
    }
}
