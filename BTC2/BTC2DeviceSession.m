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

@implementation BTC2DeviceSession

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
    
    // If found wallet address characteristic, read it
    for (CBCharacteristic* characteristic in service.characteristics){
        DLog(@"%@", characteristic.UUID);
        // TODO: Don't read everything. Just what we want.
        // [peripheral readValueForCharacteristic:characteristic];
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarWriteUUID]]) {
//            [peripheral writeValue:[@"http://www.robohash.org/haxxorrobot.png?size=100x100" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//        }

        // Wallet service
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }

        // Identification service
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarServiceReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarIDReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        // Service Provider Service
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    DLog(@"didUpdateValueForCharacteristic. Err: %@", error);
    
    // Could be partial value, stitch together 
    NSString* stringValue = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    DLog(@" Characteristic [%@] : %@", characteristic.UUID, stringValue);
    
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
