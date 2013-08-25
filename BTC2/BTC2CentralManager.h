//
//  BTC2CentralManager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTC2CentralManager : NSObject<CBCentralManagerDelegate>
@property (nonatomic, readonly) CBCentralManager* centralManager;
@property (nonatomic, strong) NSArray* sessions;
@property (nonatomic, readonly) NSArray* activeSessions;
@property (nonatomic, strong) CBPeripheral* foundPeripheral; // Obsolete
+ (BTC2CentralManager*)manager;
-(void)startScan;
-(void)cleanup;
@end
