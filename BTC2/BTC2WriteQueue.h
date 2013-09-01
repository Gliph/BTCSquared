//
//  BTC2WriteQueue.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/31/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTC2WriteQueue : NSObject
@property (nonatomic, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) CBCentral* central;
-(void)enqueueData:(NSData*)data forCharacteristic:(CBMutableCharacteristic*)characteristic;
-(BOOL)writeNextChunk;
-(void)clear;
@end
