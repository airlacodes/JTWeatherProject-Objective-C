//
//  TimeItemCell.h
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 11/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@end
