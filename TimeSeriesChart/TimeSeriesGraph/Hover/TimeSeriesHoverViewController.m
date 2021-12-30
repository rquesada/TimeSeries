//
//  TimeSeriesHoverViewController.m
//  TimeSeriesChart
//
//  Created by Roy Quesada on 6/3/21.
//

#import "TimeSeriesHoverViewController.h"
#import "DateValueFormatter.h"
#import "TimeSeriesChart-Swift.h"

@interface TimeSeriesHoverViewController () <ChartViewDelegate>
@property (weak, nonatomic) IBOutlet CustomLineChart *timeSeriesGraph;
@property NSMutableArray *values1, *values2;
@property (strong, nonatomic) ChartHighlight *lastHighlight;
@property (assign) BOOL isHighlight;
@end

@implementation TimeSeriesHoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isHighlight  = false;
    _timeSeriesGraph.delegate = self;
    _timeSeriesGraph.drawGridBackgroundEnabled = NO;
    _timeSeriesGraph.legend.enabled = NO;
    _timeSeriesGraph.doubleTapToZoomEnabled = NO;
    
    
    //(dataProvider: LineChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    _timeSeriesGraph.renderer = [[CustomLineRendererView alloc] initWithDataProvider:_timeSeriesGraph
                                                                        animator: _timeSeriesGraph.chartAnimator
                                                                 viewPortHandler:_timeSeriesGraph.viewPortHandler];
    
    
    //Marker for highlight
    ChartMarkerImage *marker = [[ChartMarkerImage alloc] init];
    marker.image = [UIImage imageNamed:@"ic_redPoint"];
    marker.size = CGSizeMake(10.0, 10.0);
    marker.chartView = _timeSeriesGraph;
    marker.offset = CGPointMake(-5, -5);
    _timeSeriesGraph.marker = marker;
    
    
    /*ChartMarkerView *marker = (ChartMarkerView *)[ChartMarkerView viewFromXibIn:[NSBundle mainBundle]];
    //marker.frame = CGRectMake(0, 0, 100, 20);
    marker.offset = CGPointMake(-5, -5);
    marker.chartView = _timeSeriesGraph;
    _timeSeriesGraph.marker = marker;*/
    
    [self setupAxis];
    [self setupData];
}

- (void) setupAxis{
    ChartXAxis *xAxis = _timeSeriesGraph.xAxis;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.labelTextColor = UIColor.darkGrayColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.granularity = 3600.0;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = _timeSeriesGraph.leftAxis;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.granularityEnabled = YES;
    
    leftAxis.labelTextColor = UIColor.darkGrayColor;
    leftAxis.drawAxisLineEnabled = NO;
    leftAxis.drawZeroLineEnabled = NO;
    
    _timeSeriesGraph.rightAxis.enabled = NO;
    _timeSeriesGraph.legend.form = ChartLegendFormLine;
}
- (void)setupData
{
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:[self getRandomDataSet]];
    [dataSets addObject:[self getRandomDataSet]];
    [dataSets addObject:[self getRandomDataSet]];
        
    
    //Add Sets to graph
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0]];
    
    _timeSeriesGraph.data = data;
    
}

- (LineChartDataSet *)getRandomDataSet
{
    NSMutableArray<CustomEntryData*> *values = [[NSMutableArray alloc] init];
    NSDate *currDate = [NSDate date];

    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    [dayComponent setDay:-7];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    currDate = [calendar dateByAddingComponents:dayComponent toDate:currDate options:0];
    [dayComponent setDay:1];
    for (int i = 1; i < 7; i++) {
        double y = arc4random_uniform(100);
        double x = floorf([currDate timeIntervalSince1970]);
        
        if (i == 5){
            CustomEntryData *entryData = [[CustomEntryData alloc] initWithX:x y:y dataStatus: DataStatusBeforeMetricStartDate];
            [values addObject:entryData];
        }else{
            CustomEntryData *entryData = [[CustomEntryData alloc] initWithX:x y:y dataStatus: DataStatusReady];
            [values addObject:entryData];
        }
        
        currDate = [calendar dateByAddingComponents:dayComponent toDate:currDate options:0];
    }
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithEntries:values label:@"DataSet"];
    [set setLineCapType:kCGLineCapRound];
    UIColor *color = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    [set setColor: color]; //[UIColor pinterestBlueColor]];
    set.fillColor = color;
    set.axisDependency = AxisDependencyLeft;
    set.lineWidth = 3.0;
    set.drawCirclesEnabled = NO;
    set.drawValuesEnabled = NO;
    
    //Hover
    set.drawHorizontalHighlightIndicatorEnabled = NO;
    set.highlightColor = [UIColor blackColor];
    set.highlightLineWidth = 2.0;
    
    return set;
}

#pragma mark - ChartViewDelegate



- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    
    NSLog(@"chartValueSelected");
    NSArray *high = _timeSeriesGraph.highlighted;
    ChartHighlight *horiginal = [high objectAtIndex:0];
    
    
    if (self.isHighlight) {
        if ( self.lastHighlight != nil && self.lastHighlight.x == horiginal.x){
            [_timeSeriesGraph highlightValues:[[NSMutableArray alloc] init]];
            self.isHighlight = false;
            return;
        }
    }
    
    self.lastHighlight = horiginal;
    
    
    NSMutableArray *highlights = [[NSMutableArray alloc] init];
    
    for (int i=0; i<= (int)self.timeSeriesGraph.data.dataSets.count; i++) {
        ChartHighlight *highlight1 = [[ChartHighlight alloc] initWithX:horiginal.x dataSetIndex:i stackIndex:i];
        [highlights addObject:highlight1];
    }
    
    [_timeSeriesGraph highlightValues:highlights];
    self.isHighlight = true;
}

- (NSArray *) getDataSet: (CGFloat) xValue{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.x = %f", xValue];
    NSArray *values = [_timeSeriesGraph.data.dataSets filteredArrayUsingPredicate:predicate];
    return values;
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
