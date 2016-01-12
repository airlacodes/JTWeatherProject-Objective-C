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

#import "KFOpenWeatherMapAPIClient.h"
#import <ChameleonFramework/Chameleon.h>

@interface DayListViewController () {

    /*! users location as Coordinate*/
    CLLocationCoordinate2D _locationCoordinate;

    /*! used to stop CLLocation constantly updating location */
    BOOL _didGetLocation;

    /*! API Response Model for weather information */
    KFOWMDailyForecastResponseModel *_responseModel;
}

/*! Blur Visual Effect view to expand days weather */
@property (weak, nonatomic) IBOutlet FullDayOverlayView *fullDayOverlay;

/*! Weather API for getting weather information from OpenWeather API */
@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;

/*! array of daily forecast objects */
@property (nonatomic, strong) NSMutableArray *weatherDaysData;

/*! English list of days for cell title, TODO: localise strings */
@property (nonatomic, strong) NSMutableArray *listOfDays;

/*! Class reference to CLLocation delegate */
@property (strong, nonatomic) CLLocationManager *locationManager;

/* Expands Location into more useful data (town, postecode etc)*/
@property (strong, nonatomic) CLPlacemark *placeMarker;

@end


@implementation DayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fullDayOverlay.hidden = YES;
    _dayListTableView.backgroundColor = [UIColor flatGreenColor];
    _weatherDaysData = [NSMutableArray array];

    /// Get the current day to eventually get the next 4 days
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    _listOfDays = [self _generateDays:[dateFormatter stringFromDate:[NSDate date]]];

    // Get current location, which will then trigger OpenWeatherApi search
    [self _initLocationManager];

    /// listen for when the day overlay blur is closed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_dayClosed)
                                                 name:kFullDayOverlayDidExitNotification
                                               object:nil];
}

- (void)_dayClosed {
    /// Show navigation bar again as overlay is closed
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int temp = [[[_responseModel.list valueForKeyPath:@"temperature.max"] objectAtIndex:indexPath.row] intValue];
    /// BUG : API Always gives back kelvin, so we have to force conversion to celcius.
    NSNumber *celcius = [self.apiClient kelvinToCelcius:[NSNumber numberWithInt:temp]];
    NSString* formattedTemp = [NSString stringWithFormat:@"%.01f", [celcius floatValue]];


    KFOWMDailyForecastListModel *listModel = _weatherDaysData[indexPath.row];
    /// set up full day details
    _fullDayOverlay.dailyForecastModel = listModel;
    _fullDayOverlay.currentLocation = _locationManager.location;
    _fullDayOverlay.tempLabel.text = formattedTemp;
    _fullDayOverlay.dayLabel.text = [_listOfDays objectAtIndex:indexPath.row];
    _fullDayOverlay.locationLabel.text = [NSString stringWithFormat:@"%@, %@", _placeMarker.locality, _placeMarker.ISOcountryCode];
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
    /// let full overlay know we loaded them as there is no viewDidLoad in a UIVisualEffectView
    [[NSNotificationCenter defaultCenter] postNotificationName:kFullDayOverlayDidLoadNotification object:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weatherDaysData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /// Get weather details for the day index
    KFOWMDailyForecastListModel *listModel = _weatherDaysData[indexPath.row];
    KFOWMWeatherModel *weatherModel = listModel.weather[0];

    /// get the 5 colours from ChameleonFramework
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous
                                                                                                  usingColor:[UIColor flatMagentaColor]
                                                                                              withFlatScheme:YES]];
    /// nicer selection highlight for cell
    UIImageView *cellSelectionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewSelectorLight.png"]];
    cellSelectionImage.alpha = 0.1;

    /// Configure cell
    DayItemCell *dayCell = [tableView dequeueReusableCellWithIdentifier:@"day_item_cell"];
    dayCell.backgroundColor = [colorArray objectAtIndex:indexPath.row];
    dayCell.selectedBackgroundView = cellSelectionImage;
    dayCell.dayLabel.text = [_listOfDays objectAtIndex:indexPath.row];
    dayCell.dayDescription.text = [weatherModel valueForKey:@"weatherDescription"];
    return dayCell;
}

#pragma mark - UITableViewDataSource

- (void)_loadTableViewData {
    self.apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:kOpenWeatherAPIKey andAPIVersion:kOpenWeatherAPIVersion];
    // Requesting five days for some reason, the api gives yesterday. Hack = ask for 6.
    [self.apiClient dailyForecastForCoordinate:_locationCoordinate numberOfDays:6 withResultBlock:^(BOOL success, id responseData, NSError *error) {
        if (success) {
            _responseModel = (KFOWMDailyForecastResponseModel *)responseData;

            /// runs 5 times (5 days)
            for (int i = 1; i < [_responseModel count]; i++) {
                [_weatherDaysData addObject:_responseModel.list[i]];
            }
            [_dayListTableView reloadData];
        }
        else {
            NSLog(@"could not get daily forecast_________: %@", error);
            [AppDelegate commonAlert:@"Fail" message:@"Failed to get Forecast"];
        }
    }];
}

#pragma mark - Day Management

/*Get index of current day and return the next 4 Bit of a hack, I'm sure there's a library for this somwhere */
- (NSMutableArray *)_generateDays:(NSString *)today {
    NSMutableArray *dayList = [NSMutableArray array];
    NSArray *week = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    NSInteger todayIndex = [week indexOfObject:today];

    /// Run 5 times to give us 5 days
    for (int i = 0; i < 5; i++) {
        if (todayIndex > 6) {
            /// avoid out of bound error as we go past Sunday, reset to 0 (Monday)
            todayIndex = 0;
        }
        /// add the right day, then go to the next day
        [dayList insertObject:[week objectAtIndex:todayIndex] atIndex:i];
        todayIndex = todayIndex + 1;
    }
    /// UX, mark what day today is. (will always be at top of list)
    [dayList replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ (Today)", today]];
    return dayList;
}

#pragma mark - CoreLocation / Location Management
/*! Get current Location & Error handle */
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

/*Create PlaceMarker from long + lat*/
- (void)_setLocationDetails:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
       completionHandler:^(NSArray *placemarks, NSError *error) {
           if (error){
               [AppDelegate commonAlert:@"Fail" message:@"Fail to find your location details"];
               return;
           }
           _placeMarker = [placemarks objectAtIndex:0];

           /// give the navigation bar a title based on location
           self.title = [NSString stringWithFormat:@"%@ Forecast", _placeMarker.locality];
       }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LOCATION ERROR_________: %@", error.localizedDescription);
    [AppDelegate commonAlert:@"Enable Location Services" message:@"Please enable location services for this app."];
}

@end
