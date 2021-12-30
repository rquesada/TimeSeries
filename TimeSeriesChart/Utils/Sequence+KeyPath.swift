//
//  Sequence+KeyPath.swift
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/26/21.
//

import Foundation

extension Sequence {
    func max<T>(
        by keyPath: KeyPath<Element, T>,
        areInIncreasingOrder: (T, T) -> Bool
    ) -> Element? {
        self.max { areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }

    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        max(by: keyPath, areInIncreasingOrder: <)
    }
}
