//
//  DayListViewController.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 09/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import "DayListViewController.h"
#import "AppDelegate.h"
#import "DayItemCell.h"

#import <ChameleonFramework/Chameleon.h>

#import "KFOpenWeatherMapAPIClient.h"
#import "KFOWMWeatherResponseModel.h"
#import "KFOWMMainWeatherModel.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastResponseModel.h"
#import "KFOWMCityModel.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"
#import "KFOWMSearchResponseModel.h"
#import "KFOWMSystemModel.h"
int const kAmountOfDays = 5;

@interface DayListViewController ()
@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;
@property (nonatomic, strong) NSMutableArray *weatherDays;
@property (nonatomic, strong) NSMutableArray *listOfDays;
@end

@implementation DayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /// set data source + delegate for tableview
    _dayListTableView.delegate = self;
    _dayListTableView.dataSource = self;
    _weatherDays = [NSMutableArray array];

    /// Get day of the week in English
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];

    ///Use current day to get the next remaining 4
    _listOfDays = [self _generateDays:[dateFormatter stringFromDate:[NSDate date]]];

    self.apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:kOpenWeatherAPIKey andAPIVersion:@"2.5"];
    [self.apiClient dailyForecastForCityName:@"London" numberOfDays:kAmountOfDays withResultBlock:
     ^(BOOL success, id responseData, NSError *error) {
         if (success) {
             KFOWMDailyForecastResponseModel *responseModel = (KFOWMDailyForecastResponseModel *)responseData;

             for (int i = 0; i < [responseModel count]; i++) {
                 /// _weatherDays contains weather models of each day
                 [_weatherDays addObject:responseModel.list[i]];
             }
             [_dayListTableView reloadData];
         }
         else {
             NSLog(@"could not get daily forecast: %@", error);
         }
     }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weatherDays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayItemCell *dayCell = [tableView dequeueReusableCellWithIdentifier:@"day_item_cell"];
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous usingColor:[UIColor flatMagentaColor] withFlatScheme:YES]];
    
    
    dayCell.backgroundColor = [colorArray objectAtIndex:indexPath.row];

    /// Get weather details for the day index
    KFOWMDailyForecastListModel *listModel = _weatherDays[indexPath.row];
    KFOWMWeatherModel *weatherModel = listModel.weather[0];

    /// Configure cell
    dayCell.dayLabel.text = [_listOfDays objectAtIndex:indexPath.row];
    dayCell.dayDescription.text = [weatherModel valueForKey:@"weatherDescription"];
    return dayCell;
}

/*Get index of current day and return the next 4 */
- (NSMutableArray *)_generateDays:(NSString *)today {
    NSMutableArray *dayList = [NSMutableArray array];
    NSArray *week = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];

    NSInteger todayIndex = [week indexOfObject:today];
    /// Run 5 times (5 days)
    for (int i = 0; i < kAmountOfDays; i++) {
        if (todayIndex > 6) {
            /// avoid out of bound error as we go pass Sunday, reset to 0 (Monday)
            todayIndex = 0;
        }
        [dayList insertObject:[week objectAtIndex:todayIndex] atIndex:i];
        /// go to next day
        todayIndex = todayIndex + 1;
    }

    [dayList replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ (Today)", today]];
    return dayList;
}
@end
