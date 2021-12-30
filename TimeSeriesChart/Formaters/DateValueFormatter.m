//
//  DateValueFormatter.m
//  TimeSeriesChart
//
//  Created by Roy Quesada on 5/26/21.
//

#import "DateValueFormatter.h"
//#import "TimeSeriesChart-Swift.h"


@interface DateValueFormatter ()
{
    NSDateFormatter *_dateFormatter;
}
@end

@implementation DateValueFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"MMM dd";
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    //Divides the X axis in 3 parts
    double part = axis.entries.count / 3;
    int index = [axis.entries indexOfObject:[NSNumber numberWithDouble:value]];
    
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
}

@end
