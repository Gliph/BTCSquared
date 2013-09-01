//
//  BTC2CentralManager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2CentralManager.h"
#import "BTC2UUIDs.h"
#import "BTC2DeviceSession.h"
#import "BTC2Events.h"

#define CONNECTION_TIMEOUT 10       // TODO: parametrize

@interface BTC2CentralManager ()
@property (nonatomic, readwrite, strong) CBCentralManager* centralManager;
@property (nonatomic, strong) CBPeripheral* connectedPeripheral; // Obsolete
@property (nonatomic, assign) BOOL shouldScan;
@property (nonatomic, strong) NSTimer* connectionTimeout; // Allow x seconds to connect, then stop
@property (nonatomic, strong) dispatch_queue_t centralQueue;
@property (nonatomic, strong) NSMutableArray* deviceSessions;
-(void)addDevice:(BTC2DeviceSession*)newSession;
-(void)connectionDidTimeout:(NSTimer*)timer;
-(void)disconnectPeripheral;
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
        manager = [[super allocWithZone:NULL] init];
    });
    
    return manager;
}

-(id)init{
    if ((self = [super init])) {
        self.centralQueue = dispatch_queue_create("ph.gli.btc2.centralqueue", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue];
        self.shouldScan = NO;
    }
    return self;
}

-(void)cleanup{
    DLog(@" Cleanup: STOPPING SCAN");

    self.shouldScan = NO;
    self.deviceSessions = nil;
    
    [self disconnectPeripheral]; // <-- Disconnect all peripherals not just one. 
    [self.centralManager stopScan];
}

-(void)addDevice:(BTC2DeviceSession*)newSession{
    if (!self.deviceSessions) {
        self.deviceSessions = [NSMutableArray arrayWithCapacity:1];
    }
    
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
        if (s.peripheral.isConnected) return YES;
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
    
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kBTC2WalletServiceUUID]] options:nil];
}


-(void)disconnectPeripheral{
    // TODO: Rewrite
    if (self.connectedPeripheral) {
        DLog(@"Disconnecting peripheral: %@", self.connectedPeripheral.name);
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self stopConnectionTimer];
    }
}

-(void)connectionDidTimeout:(NSTimer*)timer{
    DLog(@" + Connection timed out: %@", self.connectedPeripheral.name);
    [self disconnectPeripheral];
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
        
        [self addDevice:session];
        
        // TODO: This is not posted on the main thread, which it needs to be. 
        [[NSNotificationCenter defaultCenter] postNotificationName:kBTC2DidDiscoverPeripheralNotification object:session];
    }
    
    self.connectedPeripheral = peripheral;
    self.foundPeripheral = peripheral;
    
//    [self startConnectionTimer];
//    [central stopScan];
//    [central connectPeripheral:peripheral options:nil];

}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    DLog(@"didConnectPeripheral: %@", peripheral.name);

    BTC2DeviceSession* session = [self sessionForPeripheral:peripheral];

//    [self stopConnectionTimer];
    self.connectedPeripheral.delegate = session;
    [self.connectedPeripheral discoverServices:peripheral.services];

}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"didFailToConnectPeripheral - Reason: %@", error);
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"didDisconnectPeripheral - Reason: %@", error);
    self.connectedPeripheral = nil;
}


@end
