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
#import "FullDayOverlayView.h" 
#import <ChameleonFramework/Chameleon.h>

#import "KFOpenWeatherMapAPIClient.h"
#import "KFOWMWeatherResponseModel.h"
#import "KFOWMMainWeatherModel.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastResponseModel.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"
#import "KFOWMSearchResponseModel.h"

@interface DayListViewController () {
    CLLocationCoordinate2D _locationCoordinate;
    BOOL _didGetLocation;
    NSString *locationDescription;
    KFOWMDailyForecastResponseModel *_responseModel;
}
@property (weak, nonatomic) IBOutlet FullDayOverlayView *fullDayOverlay;
@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;
@property (nonatomic, strong) NSMutableArray *weatherDays;
@property (nonatomic, strong) NSMutableArray *listOfDays;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLPlacemark *placeMarker;

@end

@implementation DayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dayListTableView.backgroundColor = [UIColor flatGreenColor];
    _fullDayOverlay.hidden = YES;

    _dayListTableView.delegate = self;
    _dayListTableView.dataSource = self;

    _weatherDays = [NSMutableArray array];

    /// Get day of the week in English
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];

    // Get current location, which will then trigger weather search
    [self _initLocationManager];

    ///Use current day to get the next remaining 4
    _listOfDays = [self _generateDays:[dateFormatter stringFromDate:[NSDate date]]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_dayClosed)
                                                 name:kFullDayOverlayDidExitNotification
                                               object:nil];
}

- (void)_dayClosed {
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //prepare weather model
    KFOWMDailyForecastListModel *listModel = _weatherDays[indexPath.row];
    _fullDayOverlay.dailyForecastModel = listModel;
    _fullDayOverlay.currentLocation = _locationManager.location; 

    int temp = [[[_responseModel.list valueForKeyPath:@"temperature.max"] objectAtIndex:indexPath.row] intValue];
    NSNumber *celcius = [self.apiClient kelvinToCelcius:[NSNumber numberWithInt:temp]];
    NSString* formattedTemp = [NSString stringWithFormat:@"%.01f", [celcius floatValue]];
    _fullDayOverlay.tempLabel.text = formattedTemp;
    
    ///prepopulate labels
    _fullDayOverlay.dayLabel.text = [_listOfDays objectAtIndex:indexPath.row];
    _fullDayOverlay.locationLabel.text = locationDescription;
    [_fullDayOverlay loadDayDetails]; 
    // Animate full day overlay
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [UIView transitionWithView:_fullDayOverlay
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    self.navigationController.navigationBar.hidden = YES;
    _fullDayOverlay.hidden = NO;
      [[NSNotificationCenter defaultCenter] postNotificationName:kFullDayOverlayDidLoadNotification object:nil];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weatherDays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayItemCell *dayCell = [tableView dequeueReusableCellWithIdentifier:@"day_item_cell"];

    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous usingColor:[UIColor flatMagentaColor] withFlatScheme:YES]];
    dayCell.backgroundColor = [colorArray objectAtIndex:indexPath.row];

    UIImageView *cellSelectionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewSelectorLight.png"]];
    cellSelectionImage.alpha = 0.1;
    dayCell.selectedBackgroundView = cellSelectionImage;

    /// Get weather details for the day index
    KFOWMDailyForecastListModel *listModel = _weatherDays[indexPath.row];
    KFOWMWeatherModel *weatherModel = listModel.weather[0];

    /// Configure cell
    dayCell.dayLabel.text = [_listOfDays objectAtIndex:indexPath.row];
    dayCell.dayDescription.text = [weatherModel valueForKey:@"weatherDescription"];
    return dayCell;
}

#pragma mark - Day Management

- (void)_loadTableViewData {
    self.apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:kOpenWeatherAPIKey andAPIVersion:@"2.5"];

    // Requesting five days for some reason, the api gives yesterday. Hack = ask for 6.
    [self.apiClient setTemperatureType:KFOWMTemperatureTypeCelcius];
    [self.apiClient dailyForecastForCoordinate:_locationCoordinate numberOfDays:6 withResultBlock:^(BOOL success, id responseData, NSError *error) {
        if (success) {
            _responseModel = (KFOWMDailyForecastResponseModel *)responseData;
            for (int i = 1; i < [_responseModel count]; i++) {
                /// _weatherDays contains weather models of each day
                [_weatherDays addObject:_responseModel.list[i]];

            }
            [_dayListTableView reloadData];
        }
        else {
            NSLog(@"could not get daily forecast: %@", error);
        }
    }];

}

/*Get index of current day and return the next 4 */
- (NSMutableArray *)_generateDays:(NSString *)today {
    NSMutableArray *dayList = [NSMutableArray array];
    NSArray *week = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];

    NSInteger todayIndex = [week indexOfObject:today];
    /// Run 5 times (5 days)
    for (int i = 0; i < 5; i++) {
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

#pragma mark - CoreLocation / Location Management

- (void)_initLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
        _didGetLocation = NO;
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"______LOCATION SERVICES NOT AVALIABLE");
        [AppDelegate commonAlert:@"Enable Location Services" message:@"Please enable location services for this app."];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /// prevent CLLocation being called many times.
    if (_didGetLocation == YES) {
        return;
    }
    _locationCoordinate = manager.location.coordinate;
    _didGetLocation = YES;
    [_locationManager stopUpdatingLocation];
    [self _setLocationDetails:_locationManager.location]; 
    [self _loadTableViewData];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LOCATION ERROR_________: %@", error.localizedDescription);
    [AppDelegate commonAlert:@"Enable Location Services" message:@"Please enable location services for this app."];
}

- (void)_setLocationDetails:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
       completionHandler:^(NSArray *placemarks, NSError *error) {
           if (error){
               NSLog(@"Geocode failed with error: %@", error);
               return;
           }
           _placeMarker = [placemarks objectAtIndex:0];
           self.title = [NSString stringWithFormat:@"%@ Forecast", _placeMarker.locality];
           locationDescription = [NSString stringWithFormat:@"%@, %@", _placeMarker.locality, _placeMarker.ISOcountryCode];
       }];
}
@end
