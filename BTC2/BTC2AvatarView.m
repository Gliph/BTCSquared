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
@end

@implementation BTC2AvatarView

-(void)awakeFromNib{
    CGSize imageSize = CGSizeMake(100, 100);
    self.imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.imageView.layer.cornerRadius = imageSize.width/2.0;
    self.imageView.layer.borderWidth = 5;
    self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.1 alpha:0.5];
//    self.imageView.alpha = 0;
    
    CGRect nameRect = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.imageView.frame.size.width, 22);
    self.nameLabel.frame = nameRect;
    self.nameLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.nameLabel.layer.shadowRadius = 4;
    self.nameLabel.layer.shadowOpacity = 1;
    self.nameLabel.layer.shadowOffset = CGSizeZero;
    self.nameLabel.clipsToBounds = NO;
}
@end
