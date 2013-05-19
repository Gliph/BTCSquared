//
//  NetworkController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "NetworkController.h"

@interface NetworkController()
@property (nonatomic, assign) NSInteger indicatorCounter;
+(NetworkController*)instance;
@end

@implementation NetworkController
@synthesize indicatorCounter;

#pragma mark - Private

-(id)init{
    if ((self = [super init])) {
    }
    return self;
}

+(NetworkController*)instance{
    static dispatch_once_t pred = 0;
    static NetworkController* instance = nil;
    dispatch_once(&pred, ^{
        instance = [[NetworkController alloc] init]; // or some other init method
    });
    return instance;
}

#pragma mark - Public

+(void)increaseActivity{
    [NetworkController instance].indicatorCounter++;

#if TARGET_OS_IPHONE
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif

//    NSLog(@"+1");
}
+(void)decreaseActivity{

    if ([NetworkController instance].indicatorCounter > 0) {
        [NetworkController instance].indicatorCounter--;
//        NSLog(@"-1");
    }

    // Save from over decrasing, might be unnecessary
    [NetworkController instance].indicatorCounter = MAX(0,[NetworkController instance].indicatorCounter);
    
    if ([NetworkController instance].indicatorCounter == 0) {
#if TARGET_OS_IPHONE
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
    }
}

@end
