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
//  BTC2CentralManager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2CentralManager.h"
#import "BTC2UUIDs.h"
#import "BTC2DeviceSession.h"
#import "BTC2Events.h"
#import "NSObject+BTC2Extensions.h"

#define CONNECTION_TIMEOUT 10       // TODO: parametrize

@interface BTC2CentralManager ()
@property (nonatomic, readwrite, strong) CBCentralManager* centralManager;
@property (nonatomic, assign) BOOL shouldScan;
@property (nonatomic, strong) NSTimer* connectionTimeout; // Allow x seconds to connect, then stop
@property (nonatomic, strong) dispatch_queue_t centralQueue;
@property (nonatomic, strong) NSMutableArray* deviceSessions;
-(void)addDevice:(BTC2DeviceSession*)newSession;
-(void)connectionDidTimeout:(NSTimer*)timer;
-(void)scanForPeripherals;
-(void)startConnectionTimer;
-(void)stopConnectionTimer;
-(BTC2DeviceSession*)sessionForPeripheral:(CBPeripheral*)peripheral; // Convenient data mining
@end

@implementation BTC2CentralManager

+ (BTC2CentralManager*)manager {
    
    static BTC2CentralManager *manager = nil;
    static dispatch_once_t once;
    
	dispatch_once(&once, ^(void){
        manager = [[super alloc] init];
    });
    
    return manager;
}

-(id)init{
    if ((self = [super init])) {
        self.centralQueue = dispatch_queue_create("ph.gli.btc2.centralqueue", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue];
        self.shouldScan = NO;
        self.deviceSessions = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

-(void)cleanup{
    DLog(@" Cleanup: STOPPING SCAN");

    self.shouldScan = NO;
    [self.deviceSessions removeAllObjects];
    
    [self disconnectPeripherals]; // <-- Disconnect all peripherals not just one.
    [self.centralManager stopScan];
}

-(void)addDevice:(BTC2DeviceSession*)newSession{
    DLog(@"Adding session w/ peripheral UUID: %@", newSession.peripheral.UUID);
    
    [self.deviceSessions addObject:newSession];
}

-(BTC2DeviceSession*)sessionForPeripheral:(CBPeripheral*)peripheral{
    NSUInteger idx = NSNotFound;
    BTC2DeviceSession* foundSession = nil;
    
    idx = [self.deviceSessions indexOfObjectPassingTest:^BOOL(BTC2DeviceSession* s, NSUInteger idx, BOOL *stop) {
        if (s.peripheral == peripheral) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (idx != NSNotFound) {
        foundSession = [self.deviceSessions objectAtIndex:idx];
    }
    
    return foundSession;
}

-(NSArray*)activeSessions{
    NSIndexSet* idxs = nil;
    NSArray* active = nil;
    
    idxs = [self.deviceSessions indexesOfObjectsPassingTest:^BOOL(BTC2DeviceSession* s, NSUInteger idx, BOOL *stop) {
        if (s.isConnected) return YES;
        return NO;
    }];
    
    if (idxs.count) {
        active = [self.deviceSessions objectsAtIndexes:idxs];
    }
    
    return active;
}


-(void)startScan{
    if (self.centralManager.state == CBCentralManagerStateUnknown) {
        self.shouldScan = YES;
    }else{
        [self scanForPeripherals];
    }
}

-(void)startConnectionTimer{

    [self stopConnectionTimer];
    self.connectionTimeout = [NSTimer timerWithTimeInterval:CONNECTION_TIMEOUT
                                                     target:self
                                                   selector:@selector(connectionDidTimeout:)
                                                   userInfo:nil
                                                    repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.connectionTimeout forMode:NSDefaultRunLoopMode];
}

-(void)stopConnectionTimer{
    if (self.connectionTimeout.isValid) {
        [self.connectionTimeout invalidate];
    }
}

-(void)scanForPeripherals{
    DLog(@"Start scanning for peripherals");
    
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kBTC2WalletServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(NO)}];
}

-(void)connectSession:(BTC2DeviceSession*)session{
    if (session && [session isKindOfClass:[BTC2DeviceSession class]]) {
        [self.centralManager connectPeripheral:session.peripheral options:nil];
    }
}

-(void)disconnectPeripherals{
    DLog(@"Disconnecting peripherals.");
    for (BTC2DeviceSession* session in self.deviceSessions) {
        [session disconnect];
    }
}

-(void)connectionDidTimeout:(NSTimer*)timer{
    DLog(@" + Connection timed out."); // TODO: Handle time out later
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    DLog(@"centralManagerDidUpdateState state: %d", central.state);

    switch (central.state) {
        case CBCentralManagerStatePoweredOn: // Good to go
            if (self.shouldScan) {
                [self scanForPeripherals];
            }
            break;
        case CBCentralManagerStatePoweredOff:
            [self cleanup];
            break;
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        default:
            break;
    }

}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    DLog(@"didRetrievePeripherals %@", peripherals);
    
    // TODO: Add peripherals to array
    // If not already in list, connect and read wallet address.
    
}
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    DLog(@"didRetrieveConnectedPeripherals");
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    DLog(@"didDiscoverPeripheral %@: %@", peripheral.name, peripheral.UUID);

    BTC2DeviceSession* session = [self sessionForPeripheral:peripheral];
    
    if (!session) {
        // New session
        session = [[BTC2DeviceSession alloc] init];
        session.peripheral = peripheral;
        
        // Check UUID of peripheral object and peripheral instance
        
        NSUInteger idx = [self.deviceSessions indexOfObjectPassingTest:^BOOL(BTC2DeviceSession* dev, NSUInteger idx, BOOL *stop) {
            BOOL sameUUID = NO;
            
            if (peripheral.UUID){
                if (CFEqual(dev.peripheral.UUID, peripheral.UUID)) {
                    sameUUID = YES;
                }
            }
            
            if (dev.peripheral == peripheral || sameUUID) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];

        // Don't send this out again if we already have it in store. Keep an eye on this..
        if (idx == NSNotFound) {
            [self addDevice:session];
            [NSObject btc2postNotification:kBTC2DidDiscoverPeripheralNotification withDict:@{kBTC2DeviceSessionKey: session}];
        }
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    DLog(@"didConnectPeripheral: %@", peripheral.name);

    BTC2DeviceSession* session = [self sessionForPeripheral:peripheral];

    session.peripheral.delegate = session;
    [session.peripheral discoverServices:peripheral.services];

}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"didFailToConnectPeripheral - Reason: %@", error);
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"didDisconnectPeripheral - Reason: %@", error);
}


@end
