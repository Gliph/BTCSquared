//
//  BTC2CentralDelegate.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTC2CentralDelegate : NSObject<CBCentralManagerDelegate>
@property (nonatomic, readonly) CBCentralManager* centralManager;
-(void)startScan;
-(void)cleanup;
@end
