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
//  BTC2WriteQueue.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/31/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2WriteQueue.h"

#define BTC2_CHUNK_SIZE 18

@interface BTC2QueueObject: NSObject
@property (nonatomic, strong) CBMutableCharacteristic* characteristic;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, assign) NSUInteger offset;
@end

@implementation BTC2QueueObject
@end

@interface BTC2WriteQueue ()
@property (nonatomic, strong) NSMutableArray* queue;
@end

@implementation BTC2WriteQueue

-(void)clear{
    [self.queue removeAllObjects];
}

-(void)enqueueData:(NSData*)data forCharacteristic:(CBMutableCharacteristic*)characteristic{
    BTC2QueueObject* newObject = nil;
    
    if (data.length && characteristic) {
        newObject = [[BTC2QueueObject alloc] init];
        newObject.data = data;
        newObject.characteristic = characteristic;
    
        if (!self.queue) {
            self.queue = [NSMutableArray arrayWithCapacity:1];
        }

        [self.queue addObject:newObject];
    }
}

-(BOOL)writeNextChunk{
    BTC2QueueObject* current = nil;
    NSUInteger chunkLength = 0;
    NSData* chunk = nil;
    BOOL hasMore = NO;
    bool canContinue = YES;
    
    while (canContinue && self.queue.count) {
        DLog(@"");
        current     = [self.queue objectAtIndex:0];
        chunkLength = MAX(MIN(current.data.length - current.offset, BTC2_CHUNK_SIZE),0);
        
        if (!chunkLength) {
            DLog(@"Something is clearly off. Chunk should be bigger than 0.");
            canContinue = NO;
            continue;
        }
        
        chunk = [NSData dataWithBytes:[current.data bytes] + current.offset length:chunkLength];
        
        canContinue = [self.peripheralManager updateValue:chunk
                                        forCharacteristic:current.characteristic
                                     onSubscribedCentrals:@[self.central]];
        
        if (canContinue) {
            current.offset += chunkLength;
        }

        if (current.offset >= current.data.length) {
            [self.queue removeObject:current];
        }
    }
    hasMore = (self.queue.count > 0);
    
    return hasMore;
}

@end
