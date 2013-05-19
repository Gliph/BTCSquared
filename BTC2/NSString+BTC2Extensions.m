//
//  NSString+BTC2Extensions.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/19/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "NSString+BTC2Extensions.h"

@implementation NSString (BTC2Extensions)
-(NSString *)btc2UrlEncode{
    NSString* urlEncodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)self,
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	return urlEncodedString;
}

@end
