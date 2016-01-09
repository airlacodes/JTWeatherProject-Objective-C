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

@interface DayListViewController ()
@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;
@property (nonatomic, copy) NSMutableArray *weatherDays;
@end

@implementation DayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dayListTableView.delegate = self;
    _dayListTableView.dataSource = self;
    _weatherDays = [NSMutableArray array];
    
    self.apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:kOpenWeatherAPIKey andAPIVersion:@"2.5"];
    self.apiClient.temperatureType = KFOWMTemperatureTypeCelcius;
    [self.apiClient dailyForecastForCityName:@"London" numberOfDays:5 withResultBlock:^(BOOL success, id responseData, NSError *error) {
         if (success) {
             KFOWMDailyForecastResponseModel *responseModel = (KFOWMDailyForecastResponseModel *)responseData;

             NSLog(@"received daily forecast: %@, %@", responseModel.city.cityName, [[responseModel.list valueForKeyPath:@"temperature.min"] componentsJoinedByString:@", "]);


             for (int i = 0; i < [responseModel count]; i++) {
                 [_weatherDays addObject:responseModel.list[i]];
             }

             KFOWMDailyForecastListModel *listModel = responseModel.list[0];
             NSLog(@"%@", listModel.dt);
             KFOWMWeatherModel *weatherModel = listModel.weather[0];
             NSLog(@"daily forecast first day weather icon: %@", weatherModel.toDictionary);
             [_dayListTableView reloadData];
         }
         else
         {
             NSLog(@"could not get daily forecast: %@", error);
         }
     }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weatherDays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayItemCell *dayCell = [tableView dequeueReusableCellWithIdentifier:@"day_item_cell"];
    KFOWMDailyForecastListModel *listModel = _weatherDays[indexPath.row];
    KFOWMWeatherModel *weatherModel = listModel.weather[0];

    dayCell.dayDescription.text = [weatherModel valueForKey:@"weatherDescription"];
    return dayCell;
}


@end
