/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Joakim Fernstad
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

//
//  BTC2Manager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2Manager.h"
#import "BTC2Events.h"
#import "BTC2Constants.h"
#import "BTC2DeviceSession.h"

typedef enum BTC2ManagerState {
    BTC2ManagerStateNeutral = 0,
    BTC2ManagerStateCentral,
    BTC2ManagerStatePeripheral
}BTC2ManagerState;

@interface BTC2Manager ()
@property (nonatomic, strong) NSSet* closePeripherals;
@property (nonatomic, assign) BTC2ManagerState managerState;
@end

@implementation BTC2Manager
@synthesize central;
@synthesize peripheral;
@synthesize managerState;

-(id)init{
    if ((self = [super init])){
        self.central    = [BTC2CentralManager manager];
        self.peripheral = [BTC2PeripheralManager manager];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFindPeripheral:)
                                                     name:kBTC2DidDiscoverPeripheralNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinalizeConnectionToPeripheral:)
                                                     name:kBTC2DidFinalizeConnectionNotification
                                                   object:nil];
    }
    return self;
}

-(void)didFindPeripheral:(NSNotification*)notification{
}
-(void)didFinalizeConnectionToPeripheral:(NSNotification*)notification{
    // Device connected, time to write our info to it.
    BTC2BaseSession* session = [[notification object] objectForKey:kBTC2DeviceSessionKey];
    
    if (session) {
        // A bit messy
        if ([session respondsToSelector:@selector(writeWalletModel:)]) {
            // Make sure the peripheral has our info
            BTC2DeviceSession* deviceSession = (BTC2DeviceSession*)session;
            [deviceSession writeWalletModel:self.wallet];
            [deviceSession writeIdentityModel:self.identity];
            [deviceSession writeServiceProvider:self.serviceProvider];
        }
    }
}

-(void)enterCentralMode{
    DLog(@"enterCentralMode");
    
    if (self.managerState != BTC2ManagerStateCentral ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCentralModeStarted object:nil];
        
        self.managerState = BTC2ManagerStateCentral;
        [self.central startScan];
    }
}

-(void)enterPeripheralMode{
    DLog(@"enterPeripheralMode");

    if (self.managerState != BTC2ManagerStateCentral ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralModeStarted object:nil];

        self.managerState = BTC2ManagerStatePeripheral;
        
        // Give peripheral service information
        self.peripheral.wallet          = self.wallet;
        self.peripheral.identity        = self.identity;
        self.peripheral.serviceProvider = self.serviceProvider;
        
        [self.peripheral startAdvertising];
    }
}

-(void)enterNeutralMode{
    DLog(@"enterNeutralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNeutralModeStarted object:nil];

    self.managerState = BTC2ManagerStateNeutral;
    [self.central cleanup];
    [self.peripheral cleanup];
}

@end
