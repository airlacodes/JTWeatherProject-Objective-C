//
//  FullDayOverlayView.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 10/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import "FullDayOverlayView.h"
#import "OWMWeatherAPI.h"
#import "AppDelegate.h"
#import "TimeItemCell.h"


@interface FullDayOverlayView () {
    OWMWeatherAPI *_weatherAPI;
    NSMutableArray *_rawForecastArray;
    NSMutableArray *_dailyHourForecast;
}
@property (strong, nonatomic) IBOutlet UITableView *dailyForecastTable;

@end

@implementation FullDayOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_daySelected) name:kFullDayOverlayDidLoadNotification object:nil];
}

- (void)_daySelected {
    _dailyForecastTable.delegate = self;
    _dailyForecastTable.dataSource = self;

    _rawForecastArray = [NSMutableArray array];
    _dailyHourForecast = [NSMutableArray array];

    NSDateComponents *selectedDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:_dailyForecastModel.dt];

    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:kOpenWeatherAPIKey];
    [_weatherAPI setTemperatureFormat:kOWMTempCelcius];

    [_weatherAPI forecastWeatherByCoordinate:_currentLocation.coordinate withCallback:^(NSError *error, NSDictionary *result){
            if (error) {
                NSLog(@"_______ERROR FETCHING DAY DATA");
                return;
            }

            _rawForecastArray = result[@"list"];

            for (int i = 0; i < [_rawForecastArray count]; i++) {
                NSDictionary *forecastData = [_rawForecastArray objectAtIndex:i];

                NSDateComponents *weatherDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:forecastData[@"dt"]];

                if ([weatherDate day] == [selectedDate day]) {
                    [_dailyHourForecast addObject:forecastData];
                }
            }
            [_dailyForecastTable reloadData];
    }];
}


-(IBAction)closeOverlayPressed:(id) sender {
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];

    self.hidden = YES;
}

#pragma mark - UITableViewDelegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [_dailyHourForecast count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dayForecast = [_dailyHourForecast objectAtIndex:indexPath.row];

    TimeItemCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"time_item_cell"];

    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    dateformate.dateFormat = @"HH:mm a"; // Date formater
    NSString *timeString = [dateformate stringFromDate:dayForecast[@"dt"]]; // Convert date to string
    NSLog(@"timeString :%@",timeString);


    timeCell.timeLabel.text = timeString; 
    timeCell.temperatureLabel.text = [NSString stringWithFormat:@"%.1f℃ - %@",
                                      [dayForecast[@"main"][@"temp"] floatValue],
                                      dayForecast[@"weather"][0][@"main"]
                                      ];
    return timeCell;
}

/*! Taken from Stack Overflow for tableview fading on scroll */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Fades out top and bottom cells in table view as they leave the screen
    NSArray *visibleCells = [_dailyForecastTable visibleCells];

    if (visibleCells != nil  &&  [visibleCells count] != 0) {       // Don't do anything for empty table view

        /* Get top and bottom cells */
        UITableViewCell *topCell = [visibleCells objectAtIndex:0];
        UITableViewCell *bottomCell = [visibleCells lastObject];

        /* Make sure other cells stay opaque */
        // Avoids issues with skipped method calls during rapid scrolling
        for (UITableViewCell *cell in visibleCells) {
            cell.contentView.alpha = 1.0;
        }

        /* Set necessary constants */
        NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 To allow for typical separator line height
        NSInteger tableViewTopPosition = _dailyForecastTable.frame.origin.y;
        NSInteger tableViewBottomPosition =_dailyForecastTable.frame.origin.y + _dailyForecastTable.frame.size.height;

        /* Get content offset to set opacity */
        CGRect topCellPositionInTableView = [_dailyForecastTable rectForRowAtIndexPath:[_dailyForecastTable indexPathForCell:topCell]];
        CGRect bottomCellPositionInTableView = [_dailyForecastTable rectForRowAtIndexPath:[_dailyForecastTable indexPathForCell:bottomCell]];
        CGFloat topCellPosition = [_dailyForecastTable convertRect:topCellPositionInTableView toView:[_dailyForecastTable superview]].origin.y;
        CGFloat bottomCellPosition = ([_dailyForecastTable convertRect:bottomCellPositionInTableView toView:[_dailyForecastTable superview]].origin.y + cellHeight);

        /* Set opacity based on amount of cell that is outside of view */
        CGFloat modifier = 2.0;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
                                     2.0 for fully transparent when the cell is half off the screen, etc) */
        CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
        CGFloat bottomCellOpacity = (1.0f - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier);

        /* Set cell opacity */
        if (topCell) {
            topCell.contentView.alpha = topCellOpacity;
        }
        if (bottomCell) {
            bottomCell.contentView.alpha = bottomCellOpacity;
        }
    }
}

@end
