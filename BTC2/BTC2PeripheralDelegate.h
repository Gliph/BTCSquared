//
//  BTC2PeripheralDelegate.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTC2PeripheralDelegate : NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, readonly) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) NSString* deviceName;
@property (nonatomic, strong) NSString* walletAddress;
-(void)startAdvertising;
-(void)stopAdvertising;
-(void)cleanup;
@end
