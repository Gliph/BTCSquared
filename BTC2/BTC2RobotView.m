//
//  BTC2RobotView.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2RobotView.h"
#import "ImageRequest.h"
#import <QuartzCore/QuartzCore.h>

@implementation BTC2RobotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)retrieveRobot{ // Hackathon code.. Don't judge me!
    CGRect newFrame = self.frame;
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.roboSize.width, self.roboSize.height)];
    imgView.layer.cornerRadius = self.roboSize.width/2.0; //Assume 1:1 ratio for now
    imgView.layer.borderWidth = 5;
    imgView.layer.borderColor = [UIColor blackColor].CGColor;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.1 alpha:0.5];
    imgView.alpha = 0;
    
    newFrame.size = self.roboSize;
    
    [self addSubview:imgView];
    
    // Get Mr Robot
    NSString* name = self.roboName.length?self.roboName:@"MrRobot";
    NSString* urlString = [NSString stringWithFormat:@"http://robohash.org/%@.png?size=%dx%d", name, (int)self.roboSize.width, (int)self.roboSize.height];
    ImageRequest* imgReq = [[ImageRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    imgReq.finishBlock = ^(UIImage* img){
        imgView.alpha = 0;
        imgView.image = img;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             imgView.alpha = 1;
                         }];
    
    };
    
    [imgReq execute];

}
@end
