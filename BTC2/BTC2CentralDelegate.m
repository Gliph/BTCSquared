//
//  BTC2CentralDelegate.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2CentralDelegate.h"
#import "BTC2UUIDs.h"

@interface BTC2CentralDelegate ()
@property (nonatomic, readwrite, strong) CBCentralManager* centralManager;
@property (nonatomic, assign) BOOL shouldScan;
@end

@implementation BTC2CentralDelegate
@synthesize centralManager;
@synthesize shouldScan;

-(id)init{
    if ((self = [super init])) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.shouldScan = NO;
    }
    return self;
}

-(void)cleanup{
    self.shouldScan = NO;
    [self.centralManager stopScan];
}

-(void)startScan{
    if (self.centralManager.state == CBCentralManagerStateUnknown) {
        self.shouldScan = YES;
    }else{
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BTC2WalletServiceUUID]] options:nil];
//        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"centralManagerDidUpdateState state: %d", central.state);

    switch (central.state) {
        case CBCentralManagerStatePoweredOn: // Good to go
            if (self.shouldScan) {
                NSLog(@"Start scanning for peripherals"); // @[[CBUUID UUIDWithString:BTC2WalletServiceUUID]]
//                [central scanForPeripheralsWithServices:nil options:nil];
                [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BTC2WalletServiceUUID]] options:nil];
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
    NSLog(@"didRetrievePeripherals %@", peripherals);
    
    // TODO: Add peripherals to array (if not already added)
    // 
}
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    NSLog(@"didRetrieveConnectedPeripherals");
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"didDiscoverPeripheral %@: %@", peripheral.name, peripheral.UUID);
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral");
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral");
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    NSLog(@"peripheralDidUpdateName");
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral{
    NSLog(@"peripheralDidInvalidateServices");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"peripheralDidUpdateRSSI");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"didDiscoverServices");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    NSLog(@"didDiscoverIncludedServicesForService");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"didDiscoverCharacteristicsForService");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdateValueForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didWriteValueForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdateNotificationStateForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didDiscoverDescriptorsForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didUpdateValueForDescriptor");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didWriteValueForDescriptor");
}



@end
