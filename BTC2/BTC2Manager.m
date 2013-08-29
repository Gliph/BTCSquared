//
//  BTC2Manager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2Manager.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"

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
        self.central = [[BTC2CentralManager alloc] init];
        self.peripheral = [[BTC2PeripheralManager alloc] init];
     
        BTC2WalletModel* walletModel = [[BTC2WalletModel alloc] init];
        walletModel.walletAddress = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations!
        walletModel.paymentRequest = [BTC2PaymentRequestModel requestAmount:@(1000)  withCurrency:@"BTC"];
        
        self.peripheral.wallet = walletModel;
        
        BTC2IdentityModel* idModel = [[BTC2IdentityModel alloc] init];
        
        idModel.pseudonym = @"HaxxorBot";
        idModel.avatarURL = [NSURL URLWithString:@"http://robohash.org/haxxorbot.png"];
        idModel.avatarServiceName = @"robohash";
        idModel.avatarID = @"haxxxorbot";
        
        self.peripheral.avatar = idModel;
        
        BTC2ServiceProviderModel* providerModel = [[BTC2ServiceProviderModel alloc] init];
        providerModel.serviceName = @"gliph";
        providerModel.serviceUserID = @"di.di.di";
        
        self.peripheral.serviceProvider = providerModel;
    }
    return self;
}

-(void)changeState:(NSTimer*)timer{
    DLog(@"changeState");

    switch (self.managerState) {
        case BTC2ManagerStateNeutral:
            break;
        case BTC2ManagerStateCentral:
            [self enterPeripheralMode];
            break;
        case BTC2ManagerStatePeripheral:
            [self enterCentralMode];
            break;
            
        default:
            break;
    }
    
}

-(void)enterCentralMode{
    DLog(@"enterCentralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kCentralModeStarted object:nil];
    
    self.managerState = BTC2ManagerStateCentral;
    [self.central startScan];
}

-(void)enterPeripheralMode{
    DLog(@"enterPeripheralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralModeStarted object:nil];

    self.managerState = BTC2ManagerStatePeripheral;
    [self.peripheral startAdvertising];
}

-(void)enterNeutralMode{
    DLog(@"enterNeutralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNeutralModeStarted object:nil];

    self.managerState = BTC2ManagerStateNeutral;
    [self.central cleanup];
    [self.peripheral cleanup];
}

#pragma mark - BTC2DataUpdatedDelegate

-(void)btc2DidUpdateWalletProperty:(BTC2WalletPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);

    switch (property) {
        case BTC2WalletPropertyWalletAddress:
            break;
        case BTC2WalletPropertyNotice:
            break;
        case BTC2WalletPropertyPaymentRequest:
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateIdentityProperty:(BTC2IdentityPropertyEnum)property forSession:(BTC2BaseSession *)session{
    switch (property) {
        case BTC2IdentityPropertyPseudonym:
            break;
        case BTC2IdentityPropertyAvatarServiceName:
            break;
        case BTC2IdentityPropertyAvatarID:
            break;
        case BTC2IdentityPropertyAvatarURL:
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateServiceProvider:(BTC2ServiceProviderPropertyEnum)property forSession:(BTC2BaseSession *)session{
    switch (property) {
        case BTC2ServiceProviderPropertyServiceName:
            break;
        case BTC2ServiceProviderPropertyServiceUserID:
            break;
        default:
            break;
    }
}
@end
