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
@property (nonatomic, strong) CBMutableService* idService;
@property (nonatomic, strong) CBMutableService* providerService;
@property (nonatomic, assign) BOOL shouldAdvertise;
@end

@implementation BTC2PeripheralDelegate
@synthesize peripheralManager;
@synthesize walletService = m_walletService;
@synthesize idService = m_idService;
@synthesize providerService = m_providerService;
@synthesize shouldAdvertise;

-(id)init{
    if ((self = [super init])) {
        self.walletAddress  = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations welcome. ;)
        
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.shouldAdvertise   = NO;
        self.useEncryption     = NO; // I'll do this later when it's all working
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
    DLog(@"");
    
    NSDictionary* adDict = nil;
    self.shouldAdvertise = YES;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        adDict = @{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BTC2WalletServiceUUID]], // ... ARRAY of CBUUIDs
                   CBAdvertisementDataLocalNameKey: @"HaxxorRobot"}; // Baha.. TODO: Change advertisement name
        
        // System removes all services when switching to central mode. Re-add every time we start over
        [self.peripheralManager addService:self.walletService];
        
        // Optional service
        if (self.idService) {
            [self.peripheralManager addService:self.idService];
        }
        
        // Optional service
        if (self.providerService) {
            [self.peripheralManager addService:self.providerService];
        }
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
    CBMutableCharacteristic* characteristic = nil;
    NSMutableArray* characteristics = nil;
    
    BOOL encryptionEnabled = self.useEncryption;
    
    if (!m_walletService) {
        
        characteristics = [NSMutableArray arrayWithCapacity:6];
        
        //
        // Central side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletAddressReadUUID]
                                                            properties:CBCharacteristicPropertyRead
                                                                 value:[self.walletAddress dataUsingEncoding:NSUTF8StringEncoding]
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletPaymentWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletNoticeWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletAddressWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletPaymentIndicateUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyIndicateEncryptionRequired:CBCharacteristicPropertyIndicate
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletNoticeIndicateUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyIndicateEncryptionRequired:CBCharacteristicPropertyIndicate
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        walletService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BTC2WalletServiceUUID] primary:YES];
        
        walletService.characteristics = [NSArray arrayWithArray:characteristics];
        m_walletService = walletService;
    }
    
    return m_walletService;
}


// Identification service
-(CBMutableService*)idService{
    
    CBMutableService* idService = nil;
    CBMutableCharacteristic* characteristic = nil;
    NSMutableArray* characteristics = nil;
    
    BOOL encryptionEnabled = self.useEncryption;
    
    if (!m_idService) {
        
        characteristics = [NSMutableArray arrayWithCapacity:6];
        
        //
        // Central side
        //
        if (self.avatar.pseudonym) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDPseudonymReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar.pseudonym dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
        }
        
        if (self.avatar.avatarURL) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDAvatarReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar.avatarURL.absoluteString dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if ([self.avatar data]) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDAvatarURLReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar data]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDPseudonymWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDAvatarWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2IDAvatarURLWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        idService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BTC2IDServiceUUID] primary:YES];
        
        idService.characteristics = [NSArray arrayWithArray:characteristics];
        m_idService = idService;
    }
    
    return m_idService;
}


// Service provider service
-(CBMutableService*)providerService{
    
    CBMutableService* providerService = nil;
    CBMutableCharacteristic* characteristic = nil;
    NSMutableArray* characteristics = nil;
    
    BOOL encryptionEnabled = self.useEncryption;
    
    if (!m_providerService) {
        
        characteristics = [NSMutableArray arrayWithCapacity:6];
        
        //
        // Central side
        //
        if (self.serviceProvider.serviceName) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2ServiceProviderNameReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider.serviceName dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if (self.serviceProvider.serviceUserID) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2ServiceProviderUserIDReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider.serviceUserID dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
        }
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2ServiceProviderNameWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BTC2ServiceProviderUserIDWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        
        providerService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BTC2ServiceProviderServiceUUID] primary:YES];
        
        providerService.characteristics = [NSArray arrayWithArray:characteristics];
        m_providerService = providerService;
    }
    
    return m_providerService;
}


#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    DLog(@"peripheralManagerDidUpdateState state: %d", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            DLog(@"Powered ON.");
            if (self.shouldAdvertise) {
                [self startAdvertising];
            }
            break;
            
        default:
            break;
    }

}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    DLog(@"peripheralManagerDidStartAdvertising w/ error: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    DLog(@"didAddService w/ error: %@", error);
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
