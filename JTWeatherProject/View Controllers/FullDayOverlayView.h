//
//  FullDayOverlayView.h
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 10/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullDayOverlayView : UIVisualEffectView 
@property(nonatomic, weak) NSString *day; 
@property(nonatomic, weak) IBOutlet UILabel *dayLabel; 
@end
