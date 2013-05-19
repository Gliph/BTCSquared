//
//  BTC2RobotView.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTC2RobotView : UIView
@property (nonatomic, strong) NSString* roboName;
@property (nonatomic, assign) CGSize roboSize;
-(void)retrieveRobot;
@end
