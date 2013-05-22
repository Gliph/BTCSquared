//
//  BTC2PeripheralDelegate.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2PeripheralDelegate.h"
#import "BTC2UUIDs.h"

@interface BTC2PeripheralDelegate ()
@property (nonatomic, readwrite, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) CBMutableService* walletService;
@property (nonatomic, assign) BOOL shouldAdvertise;
@end

@implementation BTC2PeripheralDelegate
@synthesize peripheralManager;
@synthesize deviceName;
@synthesize walletService = m_walletService;
@synthesize shouldAdvertise;

-(id)init{
    if ((self = [super init])) {
        self.deviceName     = @"HaxxorRobot";
        self.walletAddress  = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations welcome. ;)

        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.shouldAdvertise   = NO;
    }
    return self;
}

-(void)cleanup{
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager removeAllServices];
    }
}

-(void)startAdvertising{

    NSDictionary* adDict = nil;
    self.shouldAdvertise = YES;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        adDict = @{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BTC2WalletServiceUUID]], // ... ARRAY of CBUUIDs
                   CBAdvertisementDataLocalNameKey: self.deviceName};
        
        // System removes all services when switching to central mode. Re-add every time we start over
        [self.peripheralManager addService:self.walletService];
        [self.peripheralManager startAdvertising:adDict];
    }
}

-(void)stopAdvertising{
    self.shouldAdvertise = NO;
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
}

// Wallet service
-(CBMutableService*)walletService{

    CBMutableService* walletService = nil;
    CBMutableCharacteristic* walletCharacteristic = nil;
    CBMutableCharacteristic* customNameCharacteristic = nil;
    
    if (!m_walletService) {
        
        walletCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletCharacteristicUUID]
                                                                  properties:CBCharacteristicPropertyRead
                                                                       value:[self.walletAddress dataUsingEncoding:NSUTF8StringEncoding]
                                                                 permissions:CBAttributePermissionsReadable];

        customNameCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletCharacteristicUUID]
                                                                      properties:CBCharacteristicPropertyRead
                                                                           value:[self.deviceName dataUsingEncoding:NSUTF8StringEncoding]
                                                                     permissions:CBAttributePermissionsReadable];
        
        walletService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletServiceUUID] primary:YES];
        
        walletService.characteristics = @[walletCharacteristic, customNameCharacteristic];
        
        m_walletService = walletService;
    }
    
    return m_walletService;
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    DLog(@"peripheralManagerDidUpdateState state: %d", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            DLog(@"Powered ON. Start advertising");
            if (self.shouldAdvertise) {
                [self startAdvertising];
            }
            break;
            
        default:
            break;
    }

}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    DLog(@"peripheralManagerDidStartAdvertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    DLog(@"didAddService");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    DLog(@"didSubscribeToCharacteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    DLog(@"didUnsubscribeFromCharacteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    DLog(@"didReceiveReadRequest");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    DLog(@"didReceiveWriteRequests");
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    DLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}

@end
