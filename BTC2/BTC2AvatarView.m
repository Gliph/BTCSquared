/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Joakim Fernstad
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

//
//  BTC2RobotView.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2AvatarView.h"
#import "ImageRequest.h"
#import "BTC2AvatarServices.h"
#import "NSString+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2AvatarView ()
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@end

@implementation BTC2AvatarView

-(void)retrieveAvatar{ // Hackathon code.. Don't judge me!
    CGSize imageSize = CGSizeMake(100, 100);
    
    if (!self.hasAvatar) {
        self.hasAvatar = YES;
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        imgView.layer.cornerRadius = imageSize.width/2.0;
        imgView.layer.borderWidth = 5;
        imgView.layer.borderColor = [UIColor blackColor].CGColor;
        imgView.clipsToBounds = YES;
        imgView.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.1 alpha:0.5];
        imgView.alpha = 0;
        
        [self addSubview:imgView];
        
        CGRect nameRect = CGRectMake(0, CGRectGetMaxY(imgView.frame), imgView.frame.size.width, self.frame.size.height - imageSize.width/2);
        self.nameLabel.frame = nameRect;
        self.nameLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.nameLabel.layer.shadowRadius = 4;
        self.nameLabel.layer.shadowOpacity = 1;
        self.nameLabel.layer.shadowOffset = CGSizeZero;
        self.nameLabel.clipsToBounds = NO;
        
        // Get Mr Robot
        NSURL* avatarImageURL = [BTC2AvatarServices avatarImageURLForService:self.identity.avatarServiceName withID:self.identity.avatarID andSize:imageSize];
        ImageRequest* imgReq  = [[ImageRequest alloc] initWithURL:avatarImageURL];

        self.nameLabel.text = self.identity.pseudonym;
        
        imgReq.finishBlock = ^(UIImage* img){
            imgView.alpha = 0;
            imgView.image = img;
            self.hasAvatar = YES;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 imgView.alpha = 1;
                             }];
        };

        imgReq.failBlock = ^(NSUInteger responseCode){
            self.hasAvatar = NO;
        };
        
        [imgReq execute];
    }
    
}
@end
