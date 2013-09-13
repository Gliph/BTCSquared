//
//  BTC2NoticeView.m
//  BTC2
//
//  Created by Joakim on 2013-09-13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
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
        self.noticeLabel.font = [UIFont systemFontOfSize:10];
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
