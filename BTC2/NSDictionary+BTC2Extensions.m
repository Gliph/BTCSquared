//
//  NSDictionary+BTC2Extensions.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/26/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "NSDictionary+BTC2Extensions.h"
#import "BTC2Constants.h"

@implementation NSDictionary (BTC2Extensions)

NSUInteger btc2Magnitude(NSUInteger number){
    NSUInteger mag = 0;
    NSUInteger testMagnitude = 1;
    
    // Integer division to test size of data
    while ((number / testMagnitude) > 0 && testMagnitude < 10000) {
        mag++;
        testMagnitude *= 10;
    }
    
    //NSAssert(testMagnitude < 10000, @"Magnitude too large for BLE!");
    
    return mag;
}

-(NSData*)btc2RenderedJSON{
    NSError* error = nil;
    NSData* modelData = nil;
    NSDictionary* modelDict = self;
    
    // 1st pass, bake json from dict
    modelData = [NSJSONSerialization dataWithJSONObject:modelDict
                                                options:0
                                                  error:&error];
    
    if (error) {
        DLog(@"%@",error);
    }
    
    // 2nd pass, insert size as first key/value pair
    NSUInteger totalSize = 0;
    NSData* sizeData = nil;
    
    totalSize  = modelData.length + kBTC2ServiceSizeKey.length + 4; // Actual payload + size payload + extra characters "":,
    totalSize += btc2Magnitude(totalSize + btc2Magnitude(totalSize)); // Add current magnitude to get the correct size calculation including the size digits themselves
    sizeData   = [[NSString stringWithFormat:@"\"%@\":%d,", kBTC2ServiceSizeKey, totalSize] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Now we need to insert this first into the payload, after the {.
    NSMutableData* finalPayload = [NSMutableData dataWithCapacity:totalSize];
    
    [finalPayload appendBytes:modelData.bytes length:1];
    [finalPayload appendData:sizeData];
    [finalPayload appendBytes:modelData.bytes+1 length:modelData.length-1];
    
#ifdef DEBUG
    NSString* debug = [[NSString alloc] initWithData:finalPayload encoding:NSUTF8StringEncoding];
    DLog(@"modelData[%d]: %@. Estimated size: %d", finalPayload.length, debug, totalSize);
#endif
    
    return finalPayload;
}


@end
