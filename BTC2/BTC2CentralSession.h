//
//  BTC2CentralSession.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2BaseSession.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTC2CentralSession : BTC2BaseSession
@property (nonatomic, strong) CBPeripheralManager* peripheral;
@end
