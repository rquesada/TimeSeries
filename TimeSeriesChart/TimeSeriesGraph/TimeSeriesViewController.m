//
//  TimeSeriesViewController.m
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/17/21.
//

#import "TimeSeriesViewController.h"
#import "TimeSeriesChart-Swift.h"

@interface TimeSeriesViewController () <ChartViewDelegate>
@property (strong, nonatomic) IBOutlet LineChartView *timeSeriesGraph;

@end

@implementation TimeSeriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _timeSeriesGraph.delegate = self;
    
    _timeSeriesGraph.dragEnabled = YES;
    [_timeSeriesGraph setScaleEnabled:YES];
    _timeSeriesGraph.pinchZoomEnabled = YES;
    _timeSeriesGraph.drawGridBackgroundEnabled = NO;
    
    _timeSeriesGraph.xAxis.drawGridLinesEnabled = NO;
    
    _timeSeriesGraph.rightAxis.enabled = NO;
    _timeSeriesGraph.leftAxis.enabled = YES;
    _timeSeriesGraph.xAxis.enabled = YES;
    _timeSeriesGraph.xAxis.spaceMin = 0.1f;
    _timeSeriesGraph.xAxis.spaceMax = 0.1f;
    
    
    _timeSeriesGraph.xAxis.labelPosition = XAxisLabelPositionBottom;
    _timeSeriesGraph.legend.enabled = NO;
    
    
    CustomLineRenderer *lineRenderer = [[CustomLineRenderer alloc] initWithDataProvider:_timeSeriesGraph
                                                                               animator:_timeSeriesGraph.chartAnimator
                                                                        viewPortHandler:_timeSeriesGraph.viewPortHandler];
    
    _timeSeriesGraph.renderer = lineRenderer;
   
    
    
    //Legend
    //_timeSeriesGraph.legend.orientation  //= ChartLegendOrientation.vertical; //  = Orientation.horizontal
    
    [self updateChartData];
}


- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _timeSeriesGraph.data = nil;
        return;
    }
    
    //[self fillGraph];// Simple line with 2 sets
    [self fillWithGap]; //1 Set with gap
    //[self setDataCount:4 range:30];
}





// 1 Set with gap
- (void) fillWithGap{
   
    //Step 1
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i++)
    {
        double val;
        switch(i){
            case 0:
                val = 10;
              break;
            case 1:
                val = 11;
              break;
            case 2:
                 val = 0;
               break;
            case 3:
                 val = 0;
               break;
            case 4:
                 val = 4;
               break;
           default :
                val = 10;
        }
        CustomEntryData *entryData = [[CustomEntryData alloc] initWithX:i y:val dataStatus: DataStatusReady];
        [values addObject:entryData];
        //[values addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    LineChartDataSet *set1 = nil;
    set1 = [[LineChartDataSet alloc] initWithEntries:values label:@"Web"];
    [set1 setColor:UIColor.blueColor];
    set1.lineWidth = 3.0;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.formLineWidth = 1.0;
    set1.formSize = 15.0;
    [set1 setLineCapType:kCGLineCapRound];
    
    set1.drawHorizontalHighlightIndicatorEnabled = NO;
    //Time Series Custom
    set1.drawValuesEnabled = NO;
    set1.drawFilledEnabled = NO;
    set1.drawCirclesEnabled = NO;
    set1.drawIconsEnabled = NO;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    
    //Step 2 GAP
    NSMutableArray *values2 = [[NSMutableArray alloc] init];
    for (int i = 8; i < 15; i++)
    {
        double val;
        switch(i){
            case 8:
                val = 10;
              break;
            case 9:
                val = 11;
              break;
            case 10:
                 val =8;
               break;
            case 11:
                 val = 8;
               break;
            case 12:
                 val = 10;
               break;
           default :
                val = 12;
        }
        [values2 addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    LineChartDataSet *set2 = nil;
    set2 = [[LineChartDataSet alloc] initWithEntries:values2 label:@"Web"];
    [set2 setColor:UIColor.blueColor];
    set2.lineWidth = 3.0;
    set2.valueFont = [UIFont systemFontOfSize:9.f];
    set2.formLineWidth = 1.0;
    set2.formSize = 15.0;
    
    
    set2.drawHorizontalHighlightIndicatorEnabled = NO;
    //Time Series Custom
    set2.drawValuesEnabled = NO;
    set2.drawFilledEnabled = NO;
    set2.drawCirclesEnabled = NO;
    set2.drawIconsEnabled = NO;
    [set2 setLineCapType:kCGLineCapRound];
    [dataSets addObject:set2];
    
    
    //Step 3 // Filled are
    NSMutableArray *values3 = [[NSMutableArray alloc] init];
    for (int i = 4; i < 9; i++)
    {
        double val = 12;
    
        [values3 addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    LineChartDataSet *set3 = [[LineChartDataSet alloc] initWithEntries:values3 label:@"Web"];
    [set3 setColor:UIColor.lightGrayColor];
    set3.valueFont = [UIFont systemFontOfSize:9.f];
    set3.formLineWidth = 0;
    set3.formSize = 15.0;
    
    
    set3.drawHorizontalHighlightIndicatorEnabled = NO;
    //Time Series Custom
    set3.drawValuesEnabled = NO;
    set3.drawFilledEnabled = YES;
    set3.drawCirclesEnabled = NO;
    set3.drawIconsEnabled = NO;
    set3.drawFilledEnabled = YES;
    set3.fillColor = UIColor.redColor;
   
    [dataSets addObject:set3];
    
    
    //[dataSets addObject:set2];
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    _timeSeriesGraph.data = data;
}


//Simple graph with 2 datasets
- (void) fillGraph{
    
    LineChartDataSet *set1 = [self setDataCount:10 range:40 color:UIColor.redColor label:@"Tablet"];
    LineChartDataSet *set2 = [self setDataCount:10 range:20 color:UIColor.blueColor label:@"Mobile"];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    _timeSeriesGraph.data = data;
}

- (LineChartDataSet *)setDataCount:(int)count
                             range:(double)range
                             color:(UIColor*)color
                             label:(NSString*)label
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double val = arc4random_uniform(range) + 3;
        [values addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    
    LineChartDataSet *set = nil;
    set = [[LineChartDataSet alloc] initWithEntries:values label:label];
    [set setColor:color];
    set.lineWidth = 3.0;
    set.valueFont = [UIFont systemFontOfSize:9.f];
    set.formLineWidth = 1.0;
    set.formSize = 15.0;
    
    set.drawHorizontalHighlightIndicatorEnabled = NO;
    //Time Series Custom
    set.drawValuesEnabled = NO;
    set.drawFilledEnabled = NO;
    set.drawCirclesEnabled = NO;
    set.drawIconsEnabled = NO;
    return  set;
    
}

@end
