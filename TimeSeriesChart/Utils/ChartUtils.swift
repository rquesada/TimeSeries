//
//  ChartUtils.swift
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/26/21.
//

import Foundation

import CoreGraphics

extension Comparable
{
    func clamped(to range: ClosedRange<Self>) -> Self
    {
        if self > range.upperBound
        {
            return range.upperBound
        }
        else if self < range.lowerBound
        {
            return range.lowerBound
        }
        else
        {
            return self
        }
    }
}
