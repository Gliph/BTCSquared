//
//  BTC2RobotView.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2RobotView.h"
#import "ImageRequest.h"
#import "NSString+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2RobotView ()
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@end

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
    

    if (!self.hasRobot) {
        self.hasRobot = YES;

        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.roboSize.width, self.roboSize.height)];
        imgView.layer.cornerRadius = self.roboSize.width/2.0;
        imgView.layer.borderWidth = 5;
        imgView.layer.borderColor = [UIColor blackColor].CGColor;
        imgView.clipsToBounds = YES;
        imgView.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.1 alpha:0.5];
        imgView.alpha = 0;
        
        [self addSubview:imgView];
        
        CGRect nameRect = CGRectMake(0, CGRectGetMaxY(imgView.frame), imgView.frame.size.width, self.frame.size.height - self.roboSize.height);
        self.nameLabel.frame = nameRect;
        self.nameLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.nameLabel.layer.shadowRadius = 4;
        self.nameLabel.layer.shadowOpacity = 1;
        self.nameLabel.layer.shadowOffset = CGSizeZero;
        self.nameLabel.clipsToBounds = NO;
        
        // Get Mr Robot
        NSString* name = self.roboName.length?self.roboName:@"MrRobot";
        NSString* urlString = [NSString stringWithFormat:@"http://robohash.org/%@.png?size=%dx%d", [name btc2UrlEncode], (int)self.roboSize.width, (int)self.roboSize.height];
        ImageRequest* imgReq = [[ImageRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        self.nameLabel.text = name;
        
        imgReq.finishBlock = ^(UIImage* img){
            imgView.alpha = 0;
            imgView.image = img;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 imgView.alpha = 1;
                             }];
            
        };

        imgReq.failBlock = ^(NSUInteger responseCode){
            self.hasRobot = NO;
        };
        
        [imgReq execute];
    }
    
}
@end
