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
//  NetworkController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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

}
+(void)decreaseActivity{

    if ([NetworkController instance].indicatorCounter > 0) {
        [NetworkController instance].indicatorCounter--;
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
