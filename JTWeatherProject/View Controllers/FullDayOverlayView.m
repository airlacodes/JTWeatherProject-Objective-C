//
//  FullDayOverlayView.m
//  JTWeatherProject
//
//  Created by Jeevan Thandi on 10/01/2016.
//  Copyright © 2016 Airla Tech Ltd. All rights reserved.
//

#import "FullDayOverlayView.h"

@implementation FullDayOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(IBAction)closeOverlayPressed:(id) sender {
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];

    self.hidden = YES;

}

@end
