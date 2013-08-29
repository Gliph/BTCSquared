//
//  BTC2DeviceSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2DeviceSession.h"
#import "BTC2UUIDs.h"
#import "BTC2CentralManager.h"
#import "BTC2Constants.h"

// Services
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2PaymentRequestModel.h"

@interface BTC2DeviceSession()
@property (nonatomic, strong) NSMutableDictionary* characteristics;
@property (nonatomic, strong) NSArray* uuidReadWhitelist;
-(void)handleJSON:(NSData*)jsonData forUUID:(CBUUID*)uuid;
-(void)executeOnMainThread:(void (^)())block;
@end

@implementation BTC2DeviceSession

#pragma mark - Public methods

-(id)init{

    if ((self = [super init])) {
        NSMutableArray* whitelist = [NSMutableArray arrayWithCapacity:7];
        
        // Static data, mostly
        [whitelist addObject:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]];

        [whitelist addObject:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]];
        [whitelist addObject:[CBUUID UUIDWithString:kBTC2IDAvatarServiceReadUUID]];
        [whitelist addObject:[CBUUID UUIDWithString:kBTC2IDAvatarIDReadUUID]];
        [whitelist addObject:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]];

        [whitelist addObject:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]];
        [whitelist addObject:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]];
        
        self.uuidReadWhitelist = [NSArray arrayWithArray:whitelist];
    }
    return self;
}

-(void)executeOnMainThread:(void (^)())block{
    __block UIBackgroundTaskIdentifier task = UIBackgroundTaskInvalid;
    
    task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Kill the offending task!
        [[UIApplication sharedApplication] endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    }];
    
    void (^executionBlock)() = ^(){
        block();
        [[UIApplication sharedApplication] endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    };
    
    dispatch_async(dispatch_get_main_queue(), executionBlock);
}

-(void)connect{
    if (self.peripheral) {
        self.peripheral.delegate = self;
        [[BTC2CentralManager manager].centralManager connectPeripheral:self.peripheral options:nil];
    }
}
-(void)disconnect{
    if (self.peripheral && self.peripheral.isConnected) {
        [[BTC2CentralManager manager].centralManager cancelPeripheralConnection:self.peripheral];
    }
}

-(void)writeNotice:(NSString *)notice{
    // TODO:
}
-(void)writePaymentRequest:(BTC2PaymentRequestModel *)paymentRequest{
    // TODO:
}
-(void)writeWalletModel:(BTC2WalletModel*)wallet{
}
-(void)writeIdentityModel:(BTC2IdentityModel*)identity{
}
-(void)writeServiceProvider:(BTC2ServiceProviderModel*)provider{
}

#pragma mark - Convenience

-(void)handleJSON:(NSData*)jsonData forUUID:(CBUUID*)uuid{

    NSError* error = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (!error) {
        if ([jsonDict isKindOfClass:[NSDictionary class]]) {
            
            // Wallet service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]]) {
                self.wallet.walletAddress = [jsonDict objectForKey:kBTC2WalletAddressKey];

                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyWalletAddress forSession:self];
                    }];
                }
            }
            // TODO: Verify this one. 
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeIndicateUUID]]) {
                self.wallet.paymentRequest = [BTC2PaymentRequestModel requestAmount:[jsonDict objectForKey:kBTC2WalletPaymentReqAmountKey]
                                                                       withCurrency:[jsonDict objectForKey:kBTC2WalletPaymentCurrencyKey]];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyPaymentRequest forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeIndicateUUID]]) {
                self.wallet.notice = [jsonDict objectForKey:kBTC2WalletNoticeKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyNotice forSession:self];
                    }];
                }
            }
            
            // Identity service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]]) {
                self.identity.pseudonym = [jsonDict objectForKey:kBTC2IdentificationPseudonymKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyPseudonym forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarServiceReadUUID]]) {
                self.identity.avatarServiceName = [jsonDict objectForKey:kBTC2IdentificationAvatarServiceKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarServiceName forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarIDReadUUID]]) {
                self.identity.avatarID = [jsonDict objectForKey:kBTC2IdentificationAvatarIDKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarID forSession:self];
                    }];
                }
            }
            
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]]) {
                self.identity.avatarURL = [NSURL URLWithString:[jsonDict objectForKey:kBTC2IdentificationAvatarURLKey]];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarURL forSession:self];
                    }];
                }
            }

            // Service provider service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]]) {
                self.serviceProvider.serviceName = [jsonDict objectForKey:kBTC2ServiceProviderNameKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateServiceProvider:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateServiceProvider:BTC2ServiceProviderPropertyServiceName forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]]) {
                self.serviceProvider.serviceUserID = [jsonDict objectForKey:kBTC2ServiceProviderUserIDKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateServiceProvider:forSession:)]) {
                    [self executeOnMainThread:^{
                        [self.delegate btc2DidUpdateServiceProvider:BTC2ServiceProviderPropertyServiceUserID forSession:self];
                    }];
                }
            }
        }else{
            DLog(@"No dictionary? %@ of class %@", jsonDict, [jsonDict class]);
        }
    }else{
        DLog(@"Error: %@", error);
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    DLog(@"peripheralDidUpdateName: %@", peripheral.name);

    // This is stupid, the iPhone renames the peripheral to.. iPhone..
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral{
    DLog(@"peripheralDidInvalidateServices");
    // We might need to re-enumerate services if this happens.
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"peripheralDidUpdateRSSI: %@. Err: %@", peripheral.RSSI, error);
    // You dawg, are you close?
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    DLog(@"didDiscoverServices - Err: %@", error);
    
    // Discover characteristics
    for (CBService* service in peripheral.services) {
        DLog(@" = Service UUID: %@", service.UUID);
        
        // Only read our custom service. Apple gets cranky if we read the GAP service characteristics
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletServiceUUID]]) {
            [peripheral discoverCharacteristics:service.characteristics
                                     forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDServiceUUID]]) {
            [peripheral discoverCharacteristics:service.characteristics
                                     forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderServiceUUID]]) {
            [peripheral discoverCharacteristics:service.characteristics
                                     forService:service];
        }
    }
}

// This is not how we setup our service
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
//    DLog(@"didDiscoverIncludedServicesForService. Err: %@", error);
//}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    DLog(@"%@ Err: %@", service, error);

    self.characteristics = [NSMutableDictionary dictionaryWithCapacity:service.characteristics.count];
    
    // If found wallet address characteristic, read it
    for (CBCharacteristic* characteristic in service.characteristics){
        DLog(@"%@", characteristic.UUID);

        // Store every characteristic we find.
        [self.characteristics setObject:characteristic forKey:characteristic.UUID];

        // Read only characteristics in the uuidReadWhitelist
        if ([self.uuidReadWhitelist containsObject:characteristic.UUID]){
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didUpdateValueForCharacteristic. Err: %@", error);

    [self handleJSON:characteristic.value forUUID:characteristic.UUID];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didWriteValueForCharacteristic. Err: %@", error);
    // Catch this to know when to send the next chunk
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didUpdateNotificationStateForCharacteristic. Err: %@", error);
    // Central decides to start or stop listening on me
}

//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    DLog(@"didDiscoverDescriptorsForCharacteristic. Err: %@", error);
//    // Might not need descriptors
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
//    DLog(@"didUpdateValueForDescriptor. Err: %@", error);
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
//    DLog(@"didWriteValueForDescriptor. Err: %@", error);
//}



@end
