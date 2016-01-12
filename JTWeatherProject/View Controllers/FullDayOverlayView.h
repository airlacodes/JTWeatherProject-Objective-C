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
#import "KFOWMWeatherResponseModel.h"
#import "KFOWMMainWeatherModel.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastResponseModel.h"
#import "KFOWMCityModel.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"
#import "KFOWMSearchResponseModel.h"
#import "KFOWMSystemModel.h"

@interface FullDayOverlayView : UIVisualEffectView <UITableViewDelegate, UITableViewDataSource, UIScrollViewAccessibilityDelegate, UIScrollViewDelegate>

@property(nonatomic, weak) NSString *day;
@property (nonatomic, weak) CLLocation *currentLocation; 
@property(nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) KFOWMDailyForecastListModel *dailyForecastModel;

- (void)loadDayDetails;
@end
