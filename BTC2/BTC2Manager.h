//
//  BTC2Manager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2CentralDelegate.h"
#import "BTC2PeripheralDelegate.h"

@interface BTC2Manager : NSObject
@property (nonatomic, strong) BTC2CentralDelegate* central;
@property (nonatomic, strong) BTC2PeripheralDelegate* peripheral;
-(void)enterCentralMode;
-(void)enterPeripheralMode;
-(void)enterNeutralMode;
-(void)startCycle;
@end
