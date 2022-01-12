//
//  CustomEntry.swift
//  TimeSeriesChart
//
//  Created by Roy Quesada on 12/8/21.
//

import Charts
import Darwin
import Foundation



@objc(CustomEntryData)
class CustomEntry: ChartDataEntry {
    
    var dataStatus: DataStatus = .ready
    
    @objc public init(x: Double, y: Double,  dataStatus:DataStatus){
        super.init(x: x, y: y)
        self.dataStatus = dataStatus
    }
    
    public required init()
    {
        super.init()
    }
    

}
