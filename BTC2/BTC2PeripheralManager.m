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
//  BTC2PeripheralManager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2PeripheralManager.h"
#import "BTC2UUIDs.h"
#import "BTC2Events.h"
#import "BTC2WriteQueue.h"
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"
#import "BTC2CentralSession.h"

@interface BTC2PeripheralManager ()
@property (nonatomic, readwrite, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, assign) BOOL shouldAdvertise;
@property (nonatomic, strong) dispatch_queue_t peripheralQueue;
@property (nonatomic, strong) BTC2WriteQueue* writeQueue;
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
        self.connectedSession = nil;
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

        if (self.identity) {
            localName = self.identity.pseudonym;
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

-(void)enqueueData:(NSData*)data forCharacteristic:(CBMutableCharacteristic*)characteristic{
    if (data.length && characteristic) {
        [self.writeQueue enqueueData:data forCharacteristic:characteristic];
        [self.writeQueue writeNextChunk];
    }
}

// Wallet service
-(CBMutableService*)walletService{
    
    CBMutableService* walletService = nil;
    CBMutableCharacteristic* characteristic = nil;
    NSMutableArray* characteristics = nil;
    
    NSAssert(self.wallet.walletAddress.length, @"Can't start wallet service without a wallet address.");
    
    BOOL encryptionEnabled = self.useEncryption;
    
    if (!m_walletService) {
        
        characteristics = [NSMutableArray arrayWithCapacity:6];
        
        //
        // Central side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]
                                                            properties:CBCharacteristicPropertyRead
                                                                 value:[self.wallet walletAddresJSON]
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletPaymentNotificationUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyNotifyEncryptionRequired:CBCharacteristicPropertyNotify
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletNoticeNotificationUUID]
                                                            properties:encryptionEnabled?CBCharacteristicPropertyNotifyEncryptionRequired:CBCharacteristicPropertyNotify
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        //
        // Peripheral side
        //
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2WalletAddressWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
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
        if (self.identity.pseudonym.length) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.identity pseudonymJSON]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
        }
        
        if (self.identity.avatarURL) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.identity avatarURLJSON]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if (self.identity.avatarServiceName.length && self.identity.avatarID.length) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarServiceReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.identity avatarServiceNameJSON]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }

        if (self.identity.avatarServiceName.length && self.identity.avatarID.length) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarIDReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.identity avatarIDJSON]
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
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarServiceWriteUUID]
                                                            properties:CBCharacteristicPropertyWrite
                                                                 value:nil
                                                           permissions:CBAttributePermissionsWriteable | (encryptionEnabled?CBAttributePermissionsWriteEncryptionRequired:0)];
        
        [characteristics addObject:characteristic];
        
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2IDAvatarIDWriteUUID]
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
        if (self.serviceProvider.serviceName.length) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider serviceNameJSON]
                                                               permissions:CBAttributePermissionsReadable | (encryptionEnabled?CBAttributePermissionsReadEncryptionRequired:0)];
            
            [characteristics addObject:characteristic];
            
        }
        
        if (self.serviceProvider.serviceUserID.length) {
            characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]
                                                                properties:CBCharacteristicPropertyRead
                                                                     value:[self.serviceProvider serviceUserIDJSON]
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

    if (!self.connectedSession) {
        self.connectedSession = [[BTC2CentralSession alloc] init];
        self.connectedSession.peripheral = self;
        
        self.writeQueue = [[BTC2WriteQueue alloc] init];
        self.writeQueue.peripheralManager = peripheral;
        self.writeQueue.central = central;
        
        // Uhmkay this is a bit messy, post notification should live somewhere else, in a more generic place.
        [self.connectedSession postNotification:kBTC2DidFinalizeConnectionNotification withDict:@{kBTC2DeviceSessionKey: self.connectedSession}];
    }
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

    // Code duplication.. ugh
    if (!self.connectedSession) {
        self.connectedSession = [[BTC2CentralSession alloc] init];
        self.connectedSession.peripheral = self;

        self.writeQueue = [[BTC2WriteQueue alloc] init];
        self.writeQueue.peripheralManager = peripheral;

        // Uhmkay this is a bit messy, post notification should live somewhere else, in a more generic place.
        [self.connectedSession postNotification:kBTC2DidFinalizeConnectionNotification withDict:@{kBTC2DeviceSessionKey: self.connectedSession}];
    }
    
    for (CBATTRequest* req in requests) {
        // Add value to the proper characteristic buffer
        if (!self.writeQueue.central) {
            self.writeQueue.central = req.central;
        }
        
        [self.connectedSession addData:req.value forCharacteristic:req.characteristic];
    }
    
    [peripheral respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    DLog(@"peripheralManagerIsReadyToUpdateSubscribers");
    // Continue to send data to central, this is mostly for characteristics with indication/notification enabled.
    // Use a object that can divide a message properly and send it in chunks.
    
    if (self.writeQueue) {
        [self.writeQueue writeNextChunk];
    }
}

@end
