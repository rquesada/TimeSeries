//
//  TimeSeriesViewController.m
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/17/21.
//

#import "TimeSeriesViewController.h"

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
    
    _timeSeriesGraph.xAxis.labelPosition = XAxisLabelPositionBottom;
    
    
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
    
    [self fillGraph];
}


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
