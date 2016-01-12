//
//  AppDelegate.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 09/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DayListViewController.h"

/
NSString *const kOpenWeatherAPIKey = @"43aab2d09d3077218bc6725afff5c36c";
NSString *const kFullDayOverlayDidLoadNotification = @"kFullDayOverlayDidLoadNotification";
NSString *const kFullDayOverlayDidExitNotification = @"kFullDayOverlayDidExitNotification";
NSString *const kBackgroundImage = @"kDetailIcon";
NSString *const kTitle = @"kTitle";
NSString *const kForecastModelKey = @"kForecastModelKey";
NSString *const kUnitType = @"kUnitType";


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DayListViewController *dayListView = [[UIStoryboard storyboardWithName:@"Main"
                                                                    bundle:nil]
                                   instantiateViewControllerWithIdentifier:@"DayListViewID"];

    UINavigationController *rootNavigationController = [[UINavigationController alloc]
                                                        initWithRootViewController:dayListView];
    self.window.rootViewController = rootNavigationController;
    return YES;
}

+ (void)commonAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
