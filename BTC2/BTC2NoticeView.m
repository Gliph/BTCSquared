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
//  BTC2NoticeView.m
//  BTC2
//
//  Created by Joakim on 2013-09-13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2NoticeView.h"

@interface BTC2NoticeView()
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* noticeLabel;
@end

@implementation BTC2NoticeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIEdgeInsets noticeInset = UIEdgeInsetsMake(5, 3, 10, 3);
        self.imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"notice-frame"] resizableImageWithCapInsets:noticeInset resizingMode:UIImageResizingModeStretch]];
        self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        self.noticeLabel.numberOfLines = 8;
        self.noticeLabel.font = [UIFont systemFontOfSize:12];
        self.noticeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.noticeLabel];
    }
    return self;
}

-(void)setNotice:(NSString *)notice{
    _notice = notice;
    
    if (_notice) {
        self.noticeLabel.text = notice;
    }
}

-(void)layoutSubviews{

    CGRect textRect = CGRectZero;
    CGRect imageRect = CGRectZero;
    
    imageRect.size = [self sizeThatFits:self.bounds.size];

    textRect.size = [self.noticeLabel.text sizeWithFont:self.noticeLabel.font
                                      constrainedToSize:CGRectInset(imageRect, 3, 3).size
                                          lineBreakMode:NSLineBreakByWordWrapping];
    textRect.origin = CGPointMake(3, 2);

    self.imageView.frame = imageRect;
    self.noticeLabel.frame = textRect;
    
    __block int64_t delta = (int64_t)(1.0e9 * 3);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

-(CGSize)sizeThatFits:(CGSize)size{
    CGRect textRect = CGRectZero;
    CGRect imageRect = CGRectZero;

    textRect.size = [self.noticeLabel.text sizeWithFont:self.noticeLabel.font
                                      constrainedToSize:size
                                          lineBreakMode:NSLineBreakByWordWrapping];
    imageRect.size = textRect.size;
    imageRect = CGRectInset(imageRect, -3, -3);
    
    return imageRect.size;
}

@end
