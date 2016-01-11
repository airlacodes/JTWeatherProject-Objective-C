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
                        kBackgroundImage : @"temp",
                        kTitle : @"Temp",
                        },
                    @{
                        kBackgroundImage : @"humidity",
                        kTitle : @"Humidity",
                        },
                    @{
                        kBackgroundImage: @"pressure",
                        kTitle: @"Pressure",
                        },
                    @{
                        kBackgroundImage : @"rain",
                        kTitle : @"Rain",
                        },
                    @{
                        kBackgroundImage: @"wind",
                        kTitle: @"Wind",
                        },
                    ];
    });

    return details;
}
