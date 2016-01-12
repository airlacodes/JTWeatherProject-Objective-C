//
//  AppDelegate.h
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 09/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Helpful Constants that are used across the app */
FOUNDATION_EXTERN NSString *const kOpenWeatherAPIKey;
FOUNDATION_EXTERN NSString *const kFullDayOverlayDidLoadNotification;
FOUNDATION_EXTERN NSString *const kFullDayOverlayDidExitNotification;
FOUNDATION_EXTERN NSString *const kBackgroundImage;
FOUNDATION_EXTERN NSString *const kTitle;
FOUNDATION_EXTERN NSString *const kForecastModelKey;
FOUNDATION_EXTERN NSString *const kUnitType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/*! Presents generic alert view */
+ (void)commonAlert:(NSString *)title message:(NSString *)message;

@property (strong, nonatomic) UIWindow *window;

@end

