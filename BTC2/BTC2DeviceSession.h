//
//  BTC2DeviceSession.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTC2BaseSession.h"

@interface BTC2DeviceSession : BTC2BaseSession<CBPeripheralDelegate>
@property (nonatomic, strong) CBPeripheral* peripheral;
-(void)connect;
-(void)disconnect;

@end
