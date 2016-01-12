//
//  FullDayOverlayView.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 10/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import "FullDayOverlayView.h"
#import "AppDelegate.h"
#import "TimeItemCell.h"
#import "DayDetailStruct.h"

#import "OWMWeatherAPI.h"

/*! fixed layout values for detail scroll */
const CGFloat IconPadding = 85.0f;
const CGFloat IconWH = 50.0f;
const CGFloat LabelH = 15.0f;
const CGFloat OffsetW = 5.0f;
const CGFloat OffsetH = 20.0f;

@interface FullDayOverlayView () {

    /*! Better OpenWeather Interaction class to get tri hourly forecast */
    OWMWeatherAPI *_weatherAPI;

    /*! Array of response data from OpenWeather, should contain full week of tri hourly daily forecast */
    NSMutableArray *_rawForecastArray;

    /*! array of 3 hourly forecast for a single day */
    NSMutableArray *_dailyHourForecast;

    /*! icon frame reference for scroll view */
    CGRect scrollDetailImageFrame;
}

/*! 3 hourly TableView */
@property (strong, nonatomic) IBOutlet UITableView *dailyForecastTable;

/*! scroll view of day details */
@property (strong, nonatomic) IBOutlet UIScrollView *detailScroll;

@end

@implementation FullDayOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    _dailyForecastTable.delegate = self;
    _dailyForecastTable.dataSource = self;
    _rawForecastArray = [NSMutableArray array];
    _dailyHourForecast = [NSMutableArray array];

    /// Listen for day selected from dayListViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_daySelected)
                                                 name:kFullDayOverlayDidLoadNotification
                                               object:nil];

}

/*! UIVisualEffect has no view did load, so this is its replacement */
- (void)_daySelected {
    _rawForecastArray = [NSMutableArray array];
    _dailyHourForecast = [NSMutableArray array];

    /// Get calendar day of the month
    NSDateComponents *selectedDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                     fromDate:_dailyForecastModel.dt];

    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:kOpenWeatherAPIKey];
    [_weatherAPI setTemperatureFormat:kOWMTempCelcius];
    [_weatherAPI forecastWeatherByCoordinate:_currentLocation.coordinate
                                withCallback:^(NSError *error, NSDictionary *result) {
            if (error) {
                [AppDelegate commonAlert:@"Error" message:@"Could not fetch weather with Location. Please try again"];
                return;
            }
            _rawForecastArray = result[@"list"];
            /// Go through weekly forecast and get day we're intested in
            for (int i = 0; i < [_rawForecastArray count]; i++) {
                NSDictionary *forecastData = [_rawForecastArray objectAtIndex:i];
                NSDateComponents *weatherDate = [[NSCalendar currentCalendar]
                                                 components:NSCalendarUnitDay
                                                 fromDate:forecastData[@"dt"]];

                if ([weatherDate day] == [selectedDate day]) {
                    /// only add the day we're selected
                    [_dailyHourForecast addObject:forecastData];
                }
            }

            [_dailyForecastTable reloadData];
    }];
}

/*! User did exit this view */
-(IBAction)closeOverlayPressed:(id) sender {
    /// Flush Scroll view for next day
    _dailyHourForecast = nil;
    _dailyForecastModel = nil;
    [[_detailScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFullDayOverlayDidExitNotification object:self];
    self.hidden = YES;
}

#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_dailyForecastTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [_dailyHourForecast count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dayForecast = [_dailyHourForecast objectAtIndex:indexPath.row];
    // Format date/time stamp to 24hr time
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm a";
    NSString *timeString = [dateFormatter stringFromDate:dayForecast[@"dt"]];

    UIImageView *cellSelectionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewSelectorLight.png"]];
    cellSelectionImage.alpha = 0.1;

    TimeItemCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"time_item_cell"];
    timeCell.selectedBackgroundView = cellSelectionImage;
    timeCell.timeLabel.text = timeString;
    timeCell.temperatureLabel.text = [NSString stringWithFormat:@"%.1f℃ - %@",
                                      [dayForecast[@"main"][@"temp"] floatValue],
                                      dayForecast[@"weather"][0][@"main"]
                                      ];
    return timeCell;
}

#pragma mark - Scroll Loader

- (void)loadDayDetails {
    _detailScroll.backgroundColor = [UIColor clearColor];
    scrollDetailImageFrame = CGRectMake(OffsetW, OffsetH, IconWH, IconWH);

    //set content size to 0 + height of frame otherwise it won't work
    _detailScroll.contentSize = CGSizeMake(0, _detailScroll.frame.size.height);
    _detailScroll.showsHorizontalScrollIndicator = NO;
    _detailScroll.canCancelContentTouches = YES;

    for (NSDictionary *day in DayDetails()) {
        UIImageView *detailIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[day objectForKey:kBackgroundImage]]];
        detailIconImageView.frame = scrollDetailImageFrame;
        [_detailScroll addSubview:detailIconImageView];

        /// Weather type description
        UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(scrollDetailImageFrame.origin.x, 0, IconWH, LabelH)];
        detailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.text = [day objectForKey:kTitle];
        [_detailScroll addSubview:detailLabel];

        id value = [_dailyForecastModel valueForKey:[day objectForKey:kForecastModelKey]];
        if (value == nil) {
            /// sometimes rain is nil instead of giving a 0
            value = [NSString stringWithFormat:@"0"];
        } else {
            value = [NSString stringWithFormat:@"%.01f", [value floatValue]];
        }

        /// Weather values (humidity, pressure etc)
        UILabel* detailValue = [[UILabel alloc]initWithFrame:CGRectMake(scrollDetailImageFrame.origin.x,IconWH+30,IconWH + 10,LabelH)];
        detailValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        detailValue.textColor = [UIColor whiteColor];
        detailValue.textAlignment = NSTextAlignmentCenter;
        detailValue.text = [NSString stringWithFormat:@"%@,%@", value, [day objectForKey:kUnitType]];
        detailValue.adjustsFontSizeToFitWidth = YES;
        [_detailScroll addSubview:detailValue];


        // put one icon after the other with appropriate spacing
        scrollDetailImageFrame.origin.x = scrollDetailImageFrame.origin.x + IconPadding;
        _detailScroll.contentSize = CGSizeMake(scrollDetailImageFrame.origin.x, _detailScroll.frame.size.height);
    }
    
}


@end
