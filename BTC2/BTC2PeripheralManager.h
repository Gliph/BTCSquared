//
//  BTC2PeripheralManager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BTC2CentralSession;
@class BTC2PeripheralManager;
@class BTC2WriteQueue;
@class BTC2WalletModel;
@class BTC2IdentityModel;
@class BTC2ServiceProviderModel;

@interface BTC2PeripheralManager : NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, readonly) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) BTC2CentralSession* connectedSession; // Can only have one
@property (nonatomic, assign) BOOL useEncryption;
@property (nonatomic, readonly) CBMutableService* walletService;
@property (nonatomic, readonly) CBMutableService* idService;
@property (nonatomic, readonly) CBMutableService* providerService;
@property (nonatomic, readonly) BTC2WriteQueue* writeQueue;

// Wallet service
@property (nonatomic, strong) BTC2WalletModel* wallet;

// ID Service
@property (nonatomic, strong) BTC2IdentityModel* identity;

// Service provider service
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;

+ (BTC2PeripheralManager*)manager;
-(void)startAdvertising;
-(void)stopAdvertising;
-(void)cleanup;
@end
