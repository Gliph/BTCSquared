//
//  BTC2PeripheralManager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTC2IdentificationModel.h"
#import "BTC2ServiceProviderModel.h"

@interface BTC2PeripheralManager : NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, readonly) CBPeripheralManager* peripheralManager;
@property (nonatomic, assign) BOOL useEncryption;

//
// Information we provide
//

// Wallet service
@property (nonatomic, strong) NSString* walletAddress;
@property (nonatomic, strong) NSString* notice;

// ID Service
@property (nonatomic, strong) BTC2IdentificationModel* avatar;

// Service provider service
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;

//
// Information the central provide
//

// TODO:
+ (BTC2PeripheralManager*)manager;
-(void)startAdvertising;
-(void)stopAdvertising;
-(void)cleanup;
@end
