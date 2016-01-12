//
//  DayDetailStruct.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 11/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
NSArray *DayDetails() {
    static dispatch_once_t onceToken;
    static NSArray *details;
    dispatch_once(&onceToken, ^{
        details = @[

                    @{
                        kBackgroundImage : @"rain",
                        kTitle : @"Rain (%)",
                        kForecastModelKey : @"rain",
                        kUnitType : @"%",

                        },
                    @{
                        kBackgroundImage: @"wind",
                        kTitle: @"Wind",
                        kForecastModelKey : @"windSpeed",
                        kUnitType : @"mph",

                        },
                    @{
                        kBackgroundImage : @"humidity",
                        kTitle : @"Humidity",
                        kForecastModelKey : @"humidity",
                        kUnitType : @"%",

                        },
                    @{
                        kBackgroundImage: @"pressure",
                        kTitle: @"Pressure",
                        kForecastModelKey : @"pressure",
                        kUnitType : @"mb",
                        },
                    ];
    });

    return details;
}
