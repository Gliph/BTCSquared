//
//  UIColor+BTC2Extensions.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/19/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "UIColor+BTC2Extensions.h"

@implementation UIColor (BTC2Extensions)
+(UIColor*)btc2RandomColor{
    return [UIColor colorWithRed:(arc4random() % 255) / 128.0
                           green:(arc4random() % 255) / 128.0
                            blue:(arc4random() % 255) / 128.0
                           alpha:1.0];
}

@end
