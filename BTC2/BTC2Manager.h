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

@interface BTC2Manager : NSObject<BTC2DataUpdatedDelegate>
@property (nonatomic, strong) BTC2CentralManager* central;
@property (nonatomic, strong) BTC2PeripheralManager* peripheral;
-(void)enterCentralMode;
-(void)enterPeripheralMode;
-(void)enterNeutralMode;
@end
