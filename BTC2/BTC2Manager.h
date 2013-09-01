//
//  BTC2Manager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2CentralManager.h"
#import "BTC2PeripheralManager.h"
#import "BTC2BaseSession.h"
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"

@interface BTC2Manager : NSObject<BTC2DataUpdatedDelegate>
@property (nonatomic, strong) BTC2CentralManager* central;
@property (nonatomic, strong) BTC2PeripheralManager* peripheral;
@property (nonatomic, strong) BTC2BaseSession* connectedSession; // TODO: Multiple sessions can be active. Rewrite

// Service information
@property (nonatomic, strong) BTC2WalletModel* wallet;
@property (nonatomic, strong) BTC2IdentityModel* identity;
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;

-(void)enterCentralMode;
-(void)enterPeripheralMode;
-(void)enterNeutralMode;
@end
