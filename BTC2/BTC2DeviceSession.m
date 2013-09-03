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
//  BTC2DeviceSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2DeviceSession.h"
#import "BTC2UUIDs.h"
#import "BTC2CentralManager.h"
#import "BTC2Constants.h"
#import "BTC2Events.h"
#import "NSObject+BTC2Extensions.h"

// Services
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2PaymentRequestModel.h"

@interface BTC2DeviceSession()
@property (nonatomic, strong) NSMutableDictionary* characteristics;
@property (nonatomic, strong) NSArray* uuidReadWhitelist;

// Convenience
-(void)writeData:(NSData*)data forCharacteristic:(CBCharacteristic*)characteristic;
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

-(void)writeData:(NSData*)data forCharacteristic:(CBCharacteristic*)characteristic{
    if (characteristic && data.length && self.peripheral) {
        [self.peripheral writeValue:data
                  forCharacteristic:characteristic
                               type:CBCharacteristicWriteWithResponse];
    }
}


#pragma mark - Actions

-(void)connect{
    if (self.peripheral) {
        self.peripheral.delegate = self;
        [[BTC2CentralManager manager] connectSession:self];
    }
}
-(void)disconnect{
    if (self.peripheral && self.peripheral.isConnected) {
        [[BTC2CentralManager manager].centralManager cancelPeripheralConnection:self.peripheral];
    }
}

-(void)writeNotice:(NSString *)notice{
    BTC2WalletModel* tmpModel = [[BTC2WalletModel alloc] init];
    CBCharacteristic* characteristic = nil;
    
    if (notice.length) {
        tmpModel.notice = notice;
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2WalletNoticeWriteUUID]];

        [self writeData:[tmpModel noticeJSON] forCharacteristic:characteristic];
    }
}

-(void)writePaymentRequest:(BTC2PaymentRequestModel *)paymentRequest{
    CBCharacteristic* characteristic = nil;
    NSData* jsonData = [paymentRequest paymentRequestJSON];
    
    if (jsonData.length) {
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2WalletPaymentWriteUUID]];

        [self writeData:jsonData forCharacteristic:characteristic];
    }
}

-(void)writeWalletModel:(BTC2WalletModel*)wallet{
    CBCharacteristic* characteristic = nil;

    if (wallet.walletAddress.length) {
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2WalletAddressWriteUUID]];
        [self writeData:[wallet walletAddresJSON] forCharacteristic:characteristic];
    }
    
    [self writeNotice:wallet.notice];
    [self writePaymentRequest:wallet.paymentRequest];
}

-(void)writeIdentityModel:(BTC2IdentityModel*)identity{
    CBCharacteristic* characteristic = nil;
    
    if (identity.pseudonym.length) {
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2IDPseudonymWriteUUID]];
        [self writeData:[identity pseudonymJSON] forCharacteristic:characteristic];
    }
    if (identity.avatarServiceName.length && identity.avatarID.length) {
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2IDAvatarServiceWriteUUID]];
        [self writeData:[identity avatarServiceNameJSON] forCharacteristic:characteristic];

        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2IDAvatarIDWriteUUID]];
        [self writeData:[identity avatarIDJSON] forCharacteristic:characteristic];
    }
    if (identity.avatarURL.absoluteString.length) {
        characteristic = [self.characteristics objectForKey:[CBUUID UUIDWithString:kBTC2IDAvatarURLWriteUUID]];
        [self writeData:[identity avatarURLJSON] forCharacteristic:characteristic];
    }
}
-(void)writeServiceProvider:(BTC2ServiceProviderModel*)provider{
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

    if (!self.characteristics) {
        self.characteristics = [NSMutableDictionary dictionaryWithCapacity:service.characteristics.count];
    }
    
    // If found wallet address characteristic, read it
    for (CBCharacteristic* characteristic in service.characteristics){
        DLog(@"%@", characteristic.UUID);

        // Store every characteristic we find.
        [self.characteristics setObject:characteristic forKey:characteristic.UUID];

        // Read only characteristics in the uuidReadWhitelist
        if ([self.uuidReadWhitelist containsObject:characteristic.UUID]){
            [peripheral readValueForCharacteristic:characteristic];
        }

        // Enable indications
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeNotificationUUID]] ||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletPaymentNotificationUUID]]){
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    [NSObject btc2postNotification:kBTC2DidFinalizeConnectionNotification withDict:@{kBTC2DeviceSessionKey: self}];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didUpdateValueForCharacteristic. Err: %@", error);

    // Assuming indications arrive here as well, used addData instead of handleJSON
    [self addData:characteristic.value forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didWriteValueForCharacteristic. %@ Err: %@", characteristic.UUID, error);
    // Catch this to know when to send the next chunk
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didUpdateNotificationStateForCharacteristic. Err: %@", error);
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
