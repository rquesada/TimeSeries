//
//  CustomLineChartRenderer.swift
//  TimeSeriesChart
//
//  Created by Roy Quesada on 12/7/21.
//

import Charts
import UIKit

@objc
public enum DataStatus: Int {
    case ready
    case estimate
    case processing
    case beforeMetricStartDate
    case beforeAudienceMetricStartDate
    case beforeAudienceMonthlyMetricStartDate
    case beforePinFormatMetricStartDate
    case beforeBusinessCreated
    case beforeDataRetentionPeriod
    case beforePinDataRetentionPeriod
    case beforeCoreMetricStartDate
    case beforePinCreated
    case beforeAccountClaimed
}

@objc(CustomLineRendererView)
class CustomLineChartRenderer: LineChartRenderer {
    
    var _xBounds = XBounds()
    var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    let processingStatusValues:[DataStatus] = [.processing,
                                                .beforeMetricStartDate,
                                                .estimate,
                                                .beforeMetricStartDate,
                                                .beforeAudienceMetricStartDate,
                                                .beforeAudienceMonthlyMetricStartDate,
                                                .beforePinFormatMetricStartDate,
                                                .beforeBusinessCreated,
                                                .beforeDataRetentionPeriod,
                                                .beforeCoreMetricStartDate,
                                                .beforePinCreated,
                                                .beforeAccountClaimed]
    
    var mShadedAreaPoints: [(CustomEntry,CustomEntry)] = []
    
    override public func drawLinear(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: _xBounds)
        }
        
        context.saveGState()

            if _lineSegments.count != pointsPerEntryPair
            {
                // Allocate once in correct size
                _lineSegments = [CGPoint](repeating: CGPoint(), count: pointsPerEntryPair)
            }

        for j in _xBounds.dropLast()
        {
            var e: ChartDataEntry! = dataSet.entryForIndex(j)
            
            if e == nil { continue }
            
            _lineSegments[0].x = CGFloat(e.x)
            _lineSegments[0].y = CGFloat(e.y * phaseY)
            
            if j < _xBounds.max
            {
                // TODO: remove the check.
                // With the new XBounds iterator, j is always smaller than _xBounds.max
                // Keeping this check for a while, if xBounds have no further breaking changes, it should be safe to remove the check
                e = dataSet.entryForIndex(j + 1)
                
                if e == nil { break }
                
                if isDrawSteppedEnabled
                {
                    _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: _lineSegments[0].y)
                    _lineSegments[2] = _lineSegments[1]
                    _lineSegments[3] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                }
                else
                {
                    _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                }
            }
            else
            {
                _lineSegments[1] = _lineSegments[0]
            }

            for i in 0..<_lineSegments.count
            {
                _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
            }
            
            if !viewPortHandler.isInBoundsRight(_lineSegments[0].x)
            {
                break
            }
            
            // Determine the start and end coordinates of the line, and make sure they differ.
            guard
                let firstCoordinate = _lineSegments.first,
                let lastCoordinate = _lineSegments.last,
                firstCoordinate != lastCoordinate else { continue }
            
            // make sure the lines don't do shitty things outside bounds
            if !viewPortHandler.isInBoundsLeft(lastCoordinate.x) ||
                !viewPortHandler.isInBoundsTop(max(firstCoordinate.y, lastCoordinate.y)) ||
                !viewPortHandler.isInBoundsBottom(min(firstCoordinate.y, lastCoordinate.y))
            {
                continue
            }
            
            var dataSetColor =  dataSet.color(atIndex: j).cgColor
            
            guard let firstEntry = dataSet.entryForIndex(j) as? CustomEntry else { return }
            guard let secondEntry = dataSet.entryForIndex(j + 1) as? CustomEntry else { return }
            
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            
            if (firstEntry.dataStatus == .estimate || secondEntry.dataStatus == .estimate){
                dataSet.drawCirclesEnabled = true
                dataSet.drawCircleHoleEnabled = false
                dataSet.circleColors = [dataSet.color(atIndex: j)]
                dataSet.circleRadius = 4
                context.setLineDash(phase: 10, lengths: [5,10])
            }else if (processEntryProperties(firstEntry: firstEntry, secondEntry: secondEntry, currentIndex: j, context: context, trans: trans)){
                dataSet.drawCirclesEnabled = false
                continue
            }else if (firstEntry.dataStatus == .ready && secondEntry.dataStatus == .ready){
                dataSetColor =  dataSet.color(atIndex: j).cgColor.copy(alpha: 0.7)!
            }
            
            // get the color that is set for this line-segment
            context.setStrokeColor(dataSetColor)
            context.strokeLineSegments(between: _lineSegments)
        }
        
        context.restoreGState()
    }
    
    func processEntryProperties(firstEntry: CustomEntry,
                                secondEntry: CustomEntry,
                                currentIndex: Int,
                                context: CGContext,
                                trans: Transformer) -> Bool{
        let lastIndex = _xBounds.range + _xBounds.min
        
        if (currentIndex == lastIndex && processingStatusValues.contains(firstEntry.dataStatus)){
            mShadedAreaPoints.append((firstEntry,secondEntry))
            drawShadedArea(context: context, dataStatus: firstEntry.dataStatus, trans: trans)
            return true
        }else if (processingStatusValues.contains(firstEntry.dataStatus)){
            mShadedAreaPoints.append((firstEntry,secondEntry))
            drawShadedArea(context: context, dataStatus: firstEntry.dataStatus, trans: trans)
            return true
        }else if(currentIndex == lastIndex && processingStatusValues.contains(secondEntry.dataStatus)){
            mShadedAreaPoints.append((firstEntry,secondEntry))
            drawShadedArea(context: context, dataStatus: secondEntry.dataStatus, trans: trans)
            return true
        }
        
        return false
    }
    
    private var _sizeBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    func drawShadedArea(context: CGContext, dataStatus: DataStatus, trans: Transformer){
        let pair1 = mShadedAreaPoints[0].0
        let pair2 = mShadedAreaPoints[0].1
        
        let phaseY = animator.phaseY
        _sizeBuffer[0].x = pair1.x
        _sizeBuffer[0].y = 0 //just to get 0
        _sizeBuffer[1].x = pair2.x
        _sizeBuffer[1].y = pair2.y * phaseY
        
        trans.pointValuesToPixel(&_sizeBuffer)
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let rect = CGRect(
            x: _sizeBuffer.first!.x,
            y: 0,
            width: (_sizeBuffer[1].x - _sizeBuffer[0].x),
            height: _sizeBuffer[0].y
        )
        
        guard let color = diagonalLineColor(.gray).cgColor.copy(alpha: 0.15) else{ return }  //getColor(dataStatus: dataStatus)
        context.setFillColor(color)
        context.fill(rect)
    }
    
    
    func getColor(dataStatus: DataStatus) -> CGColor{
        switch dataStatus{
        case .beforeMetricStartDate:
            return UIColor.gray.cgColor.copy(alpha: 0.15)!
        case .beforeAudienceMetricStartDate:
            return UIColor.blue.cgColor.copy(alpha: 0.15)! //Navy
        case .beforeAudienceMonthlyMetricStartDate:
            return UIColor.orange.cgColor.copy(alpha: 0.15)!
        case .beforePinFormatMetricStartDate:
            return UIColor.red.cgColor.copy(alpha: 0.15)!
        case .beforeBusinessCreated:
            return UIColor.green.cgColor.copy(alpha: 0.15)!
        case .beforeDataRetentionPeriod:
            return UIColor.systemGreen.cgColor.copy(alpha: 0.15)! //Pine
        case .beforePinDataRetentionPeriod:
            return UIColor.systemGreen.cgColor.copy(alpha: 0.15)! //Pine
        case .beforeCoreMetricStartDate:
            return UIColor.brown.cgColor.copy(alpha: 0.15)! //Olive
        case .beforePinCreated:
            return UIColor.gray.cgColor.copy(alpha: 0.15)! //Olive
        case .beforeAccountClaimed:
            return UIColor.purple.cgColor.copy(alpha: 0.15)! //Watermelon
        default:
            return UIColor.yellow.cgColor.copy(alpha: 0.15)!
        }
    }
    
    func diagonalLineColor(_ color:UIColor) -> UIColor {
        
        let backgroundColor = UIColor.clear
        let sqrt2: CGFloat = sqrt(2.0)
        let barThickness: CGFloat = 1.0
        let spaceThickness: CGFloat = 10.0
        let dim: CGFloat = (barThickness + spaceThickness) * sqrt2

            let img = UIGraphicsImageRenderer(size: .init(width: dim, height: dim)).image { context in

                // rotate the context and shift up
                context.cgContext.rotate(by: CGFloat.pi / 4.0)
                context.cgContext.translateBy(x: 0.0, y: -(spaceThickness + barThickness))
                
                let bar1 = UIBezierPath(rect: .init(x: 0.0, y: 0.0, width: dim * sqrt2, height: barThickness))
                let bar2 = UIBezierPath(rect: .init(x: 0.0, y: barThickness, width: dim * sqrt2, height: spaceThickness))
                
                
                let bars: [(UIColor,UIBezierPath)] = [ (color, bar1), (backgroundColor, bar2)]
                
              
                bars.forEach {  $0.0.setFill(); $0.1.fill() }
                
                // move down and paint again
                context.cgContext.translateBy(x: 0.0, y: (spaceThickness + barThickness))
                bars.forEach {  $0.0.setFill(); $0.1.fill() }
            }
            
            return UIColor(patternImage: img)
        }

}
