//
//  TimeSeriesTimelineViewController.m
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/27/21.
//

#import "TimeSeriesTimelineViewController.h"
#import "DateValueFormatter.h"


@interface TimeSeriesTimelineViewController ()
@property (weak, nonatomic) IBOutlet LineChartView *timeSeriesGraph;

@end

@implementation TimeSeriesTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timeSeriesGraph.dragEnabled = YES;
    [_timeSeriesGraph setScaleEnabled:YES];
    _timeSeriesGraph.pinchZoomEnabled = YES;
    _timeSeriesGraph.drawGridBackgroundEnabled = NO;
    _timeSeriesGraph.legend.enabled = NO;
    
    [(BarLineChartViewBase *)_timeSeriesGraph getTransformerForAxis:AxisDependencyLeft];
    
    
    //Marker for highlight
    ChartMarkerImage *marker = [[ChartMarkerImage alloc] init];
    marker.image = [UIImage imageNamed:@"ic_redPoint"];
    marker.size = CGSizeMake(10.0, 10.0);
    marker.chartView = _timeSeriesGraph;
    marker.offset = CGPointMake(-5, -5);
    //timeSeriesGraph is the main instance of the Chart
    _timeSeriesGraph.marker = marker;
    
    [self setDataCount:5 range:20];
}

- (void)setDataCount:(int)count range:(double)range
{
    
    
    ChartXAxis *xAxis = _timeSeriesGraph.xAxis;
    //xAxis.labelPosition = XAxisLabelPositionTopInside;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.labelTextColor = UIColor.darkGrayColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.granularity = 3600.0;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    DateValueFormatter *dateValueFormatter = [[DateValueFormatter alloc] init];
    xAxis.valueFormatter = dateValueFormatter;
    
    
    ChartYAxis *leftAxis = _timeSeriesGraph.leftAxis;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.granularityEnabled = YES;
    leftAxis.axisMinimum = 0.0;
    leftAxis.axisMaximum = 60.0;
    
    leftAxis.labelTextColor = UIColor.darkGrayColor;
    leftAxis.drawAxisLineEnabled = NO;
    leftAxis.drawZeroLineEnabled = NO;
    
    _timeSeriesGraph.rightAxis.enabled = NO;
    
    _timeSeriesGraph.legend.form = ChartLegendFormLine;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i += 1)
        {
            double x,y;
            if (i == 0){
                y = 10;
                x = 1621907633; //May 24
            }else if (i == 1){
                y = 20;
                x = 1621994033; // May 25
            }else if (i == 2){
                y = 10;
                x = 1622080433; //May 26
            }else if (i == 3){
                y = 40;
                x = 1622166833; //May 27
            }else {
                y = 60;
                x = 1622253233; //May 29
            }
            
            [values addObject:[[ChartDataEntry alloc] initWithX:x y:y]];
            
        }
    

    LineChartDataSet *set1 = (LineChartDataSet *)_timeSeriesGraph.data.dataSets[0];;
    set1 = [[LineChartDataSet alloc] initWithEntries:values label:@"DataSet 1"];
    set1.axisDependency = AxisDependencyLeft;
    set1.valueTextColor = UIColor.redColor;
    set1.lineWidth = 3.0;
    set1.drawCirclesEnabled = NO;
    set1.drawValuesEnabled = NO;
    
    
    //Hover
    set1.drawHorizontalHighlightIndicatorEnabled = NO;
    set1.highlightColor = UIColor.blackColor;
    set1.highlightLineWidth =  2.0;
    
    
    [set1 setColor:[UIColor colorWithRed:44/255.0 green:118/255.0 blue:224/255.0 alpha:1.0]];
    set1.drawCircleHoleEnabled = NO;
    
    
    NSMutableArray *values2 = [[NSMutableArray alloc] init];
    double x,y;
    for (int i = 0; i < 2; i++){
        switch(i){
            case 0:
                y = 60;
                x = 1622253233; //1622339633; //May 29
              break;
           default :
                y = 60;
                x = 1622280233; //May 30
        }
        [values2 addObject:[[ChartDataEntry alloc] initWithX:x y:y icon: [UIImage imageNamed:@"icon"]]];
    }
    LineChartDataSet *set2 = nil;
    set2 = [[LineChartDataSet alloc] initWithEntries:values2 label:@"Web"];
    [set2 setColor:UIColor.lightGrayColor];
    set2.lineWidth = 1.0;
    set2.formLineWidth = 1.0;
    set2.formSize = 15.0;
    
    set2.drawHorizontalHighlightIndicatorEnabled = NO;
    //Time Series Custom
    set2.drawValuesEnabled = NO;
    set2.drawFilledEnabled = YES;
    set2.drawCirclesEnabled = NO;
    set2.drawIconsEnabled = NO;
    set2.drawFilledEnabled = YES;
    set2.fillColor = UIColor.lightGrayColor;
    
    
    //Hover
    set2.highlightColor = UIColor.blackColor;
    set2.drawHorizontalHighlightIndicatorEnabled = NO;
    set2.highlightLineWidth = 2.0;
   
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
        
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0]];
    
    _timeSeriesGraph.data = data;

}

@end
