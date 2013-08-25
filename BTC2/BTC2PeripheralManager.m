//
//  BTC2PeripheralManager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2PeripheralManager.h"
#import "BTC2UUIDs.h"

@interface BTC2PeripheralManager ()
@property (nonatomic, readwrite, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) CBMutableService* walletService;
@property (nonatomic, strong) CBMutableService* idService;
@property (nonatomic, strong) CBMutableService* providerService;
@property (nonatomic, assign) BOOL shouldAdvertise;
@property (nonatomic, strong) dispatch_queue_t peripheralQueue;
@end

@implementation BTC2PeripheralManager
@synthesize peripheralManager;
@synthesize walletService = m_walletService;
@synthesize idService = m_idService;
@synthesize providerService = m_providerService;
@synthesize shouldAdvertise;

+ (BTC2PeripheralManager*)manager {
    
    static BTC2PeripheralManager *manager = nil;
    static dispatch_once_t once;
    
	dispatch_once(&once, ^(void){
        manager = [[super allocWithZone:NULL] init];
    });
    
    return manager;
}

-(id)init{
    if ((self = [super init])) {
        self.walletAddress  = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations welcome. ;)
        
        self.peripheralQueue   = dispatch_queue_create("ph.gli.btc2.peripheralqueue", DISPATCH_QUEUE_SERIAL);
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:self.peripheralQueue];
        self.shouldAdvertise   = NO;
        self.useEncryption     = NO; // I'll do this later when it's all working
    }
    return self;
}

-(void)cleanup{
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
        self.shouldAdvertise = NO;
    }
    [self.peripheralManager removeAllServices];
}

-(void)startAdvertising{
    DLog(@"");
    
    NSString* localName  = nil;
    NSDictionary* adDict = nil;
    self.shouldAdvertise = YES;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {

        // Wallet service, mandatory
        [self.peripheralManager addService:self.walletService];
        
        // Optional service
        if (self.idService) {
            [self.peripheralManager addService:self.idService];
        }
        
        // Optional service
        if (self.providerService) {
            [self.peripheralManager addService:self.providerService];
        }

        if (self.avatar) {
            localName = self.avatar.pseudonym;
        }else{
            localName = [NSString stringWithFormat:@"HaxxorRobot %d", rand() % 99];
        }
        
        adDict = @{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kBTC2WalletServiceUUID]], // ... ARRAY of CBUUIDs
                   CBAdvertisementDataLocalNameKey: localName};

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
    
    NSAssert(self.walletAddress.length, @"Can't start wallet service without a wallet address.");
    
    BOOL encryptionEnabled = self.useEncryption;
    
    if (!m_walletService) {
        
        characteristics = [NSMutableArray arrayWithCapacity:6];
        
        //
        // Central side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]
                                                            properties:CBCharacteristicPropertyRead
                                                                 value:[self.walletAddress dataUsingEncoding:NSUTF8StringEncoding]  // TBD: This could be a dynamic value
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletPaymentWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletNoticeWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletAddressWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletPaymentIndicateUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyIndicateEncryptionRequired:CBCharacteristicPropertyIndicate
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletNoticeIndicateUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyIndicateEncryptionRequired:CBCharacteristicPropertyIndicate
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        walletService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletServiceUUID] primary:YES];
        
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
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar.pseudonym dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
        }
        
        if (self.avatar.avatarURL) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar.avatarURL.absoluteString dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if ([self.avatar data]) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.avatar data]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDPseudonymWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarURLWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        idService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDServiceUUID] primary:YES];
        
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
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider.serviceName dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if (self.serviceProvider.serviceUserID) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider.serviceUserID dataUsingEncoding:NSUTF8StringEncoding]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
        }
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderNameWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        
        
        providerService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderServiceUUID] primary:YES];
        
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
    // TODO: Let app know if this failed
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    DLog(@"didAddService w/ error: %@", error);
    // TODO: Let app know if this failed
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    DLog(@"didSubscribeToCharacteristic");
    // TODO: Central connected! Create a BTC2CentralSession and pass to app
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    DLog(@"didUnsubscribeFromCharacteristic");
    // Not sure if we need to handle this.
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    DLog(@"didReceiveReadRequest");
    //Called for characteristics with dynamic data. Might be used for the wallet address.
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess]; // Normal case
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    DLog(@"didReceiveWriteRequests");
    // Keep a close eye on this one. Will be crucial for when the central offload data to the peripheral.
    // Use a object to keep track of pieces of information written per characteristic. 
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    DLog(@"peripheralManagerIsReadyToUpdateSubscribers");
    // Continue to send data to central, this is mostly for characteristics with indication/notification enabled.
    // Use a object that can divide a message properly and send it in chunks.
}

@end
