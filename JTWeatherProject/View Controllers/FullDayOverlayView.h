//
//  FullDayOverlayView.h
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 10/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "KFOpenWeatherMapAPIClient.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastResponseModel.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"

@interface FullDayOverlayView : UIVisualEffectView <UITableViewDelegate, UITableViewDataSource, UIScrollViewAccessibilityDelegate, UIScrollViewDelegate>

/*! Users current location gathered from DayListViewController */
@property (nonatomic, weak) CLLocation *currentLocation;

/*! Shows the day of the week */
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;

/*! Shows the location city / area + country code */
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

/*! Shows the temperature in degrees celcius */
@property (nonatomic, weak) IBOutlet UILabel *tempLabel;

/* Daily forecast model for scroller */
@property (strong, nonatomic) KFOWMDailyForecastListModel *dailyForecastModel;

/* super loads scroll data */
- (void)loadDayDetails;

@end
