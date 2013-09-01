//
//  BTC2Manager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2Manager.h"
#import "BTC2Events.h"
#import "BTC2Constants.h"
#import "BTC2DeviceSession.h"

typedef enum BTC2ManagerState {
    BTC2ManagerStateNeutral = 0,
    BTC2ManagerStateCentral,
    BTC2ManagerStatePeripheral
}BTC2ManagerState;

@interface BTC2Manager ()
@property (nonatomic, strong) NSSet* closePeripherals;
@property (nonatomic, assign) BTC2ManagerState managerState;
@end

@implementation BTC2Manager
@synthesize central;
@synthesize peripheral;
@synthesize managerState;

-(id)init{
    if ((self = [super init])){
        self.central    = [[BTC2CentralManager alloc] init];
        self.peripheral = [[BTC2PeripheralManager alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFindPeripheral:)
                                                     name:kBTC2DidDiscoverPeripheralNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinalizeConnectionToPeripheral:)
                                                     name:kBTC2DidFinalizeConnectionNotification
                                                   object:nil];
    }
    return self;
}

-(void)didFindPeripheral:(NSNotification*)notification{
}
-(void)didFinalizeConnectionToPeripheral:(NSNotification*)notification{
    // Device connected, time to write our info to it.
    BTC2BaseSession* session = [[notification object] objectForKey:kBTC2DeviceSessionKey];
    
    if (session) {
        // A bit messy
        if ([session respondsToSelector:@selector(writeWalletModel:)]) {
            // Make sure the peripheral has our info
            BTC2DeviceSession* deviceSession = (BTC2DeviceSession*)session;
            [deviceSession writeWalletModel:self.wallet];
            [deviceSession writeIdentityModel:self.identity];
            [deviceSession writeServiceProvider:self.serviceProvider];
        }
        
        self.connectedSession = session;
        self.connectedSession.delegate = self;
    }
}

-(void)enterCentralMode{
    DLog(@"enterCentralMode");
    
    if (self.managerState != BTC2ManagerStateCentral ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCentralModeStarted object:nil];
        
        self.managerState = BTC2ManagerStateCentral;
        [self.central startScan];
    }
}

-(void)enterPeripheralMode{
    DLog(@"enterPeripheralMode");

    if (self.managerState != BTC2ManagerStateCentral ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralModeStarted object:nil];

        self.managerState = BTC2ManagerStatePeripheral;
        
        // Give peripheral service information
        self.peripheral.wallet          = self.wallet;
        self.peripheral.identity        = self.identity;
        self.peripheral.serviceProvider = self.serviceProvider;
        
        [self.peripheral startAdvertising];
    }
}

-(void)enterNeutralMode{
    DLog(@"enterNeutralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNeutralModeStarted object:nil];

    self.managerState = BTC2ManagerStateNeutral;
    self.connectedSession = nil;
    [self.central cleanup];
    [self.peripheral cleanup];
}

#pragma mark - BTC2DataUpdatedDelegate - Debug only, the manager shouldn't really be a delegate

-(void)btc2DidUpdateWalletProperty:(BTC2WalletPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);

    switch (property) {
        case BTC2WalletPropertyWalletAddress:
            DLog(@"%@", session.wallet.walletAddress);
            break;
        case BTC2WalletPropertyNotice:
            DLog(@"%@", session.wallet.notice);
            break;
        case BTC2WalletPropertyPaymentRequest:
            DLog(@"%@", [session.wallet.paymentRequest description]);
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateIdentityProperty:(BTC2IdentityPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);

    switch (property) {
        case BTC2IdentityPropertyPseudonym:
            DLog(@"%@", session.identity.pseudonym);
            break;
        case BTC2IdentityPropertyAvatarServiceName:
            DLog(@"%@", session.identity.avatarServiceName);
            break;
        case BTC2IdentityPropertyAvatarID:
            DLog(@"%@", session.identity.avatarID);
            break;
        case BTC2IdentityPropertyAvatarURL:
            DLog(@"%@", session.identity.avatarURL);
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateServiceProvider:(BTC2ServiceProviderPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);

    switch (property) {
        case BTC2ServiceProviderPropertyServiceName:
            DLog(@"%@", session.serviceProvider.serviceName);
            break;
        case BTC2ServiceProviderPropertyServiceUserID:
            DLog(@"%@", session.serviceProvider.serviceUserID);
            break;
        default:
            break;
    }
}
@end
