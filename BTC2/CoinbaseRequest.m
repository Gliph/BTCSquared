//
//  CoinbaseRequest.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "CoinbaseRequest.h"

@implementation CoinbaseRequest

- (void)setupOperation{
    
    NSMutableURLRequest* request = nil;
    
    request = [NSMutableURLRequest requestWithURL:self.requestURL];
    
    [request setHTTPMethod:self.requestMethod];
    
    self.request = request;
    NSLog(@"Shooting off URL: %@ (%@)", self.requestURL, self.requestMethod);
}

-(id)objectFromResponse{
    UIImage* image = [UIImage imageWithData:self.storedData];
    CGFloat imageScale = 1.0;
    
    // The image we download is retina size
    if (self.isRetina) {
        imageScale = 2.0;
    }
    
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:imageScale
                          orientation:UIImageOrientationUp];
    
    return image;
}
@end
