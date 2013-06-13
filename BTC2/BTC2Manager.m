//
//  BTC2Manager.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2Manager.h"
#import "BTC2IdentificationModel.h"
#import "BTC2ServiceProviderModel.h"

typedef enum BTC2ManagerState {
    BTC2ManagerStateNeutral = 0,
    BTC2ManagerStateCentral,
    BTC2ManagerStatePeripheral
}BTC2ManagerState;

@interface BTC2Manager ()
@property (nonatomic, strong) NSSet* closePeripherals;
@property (nonatomic, strong) NSTimer* stateTimer;
@property (nonatomic, assign) BTC2ManagerState managerState;
-(void)changeState:(NSTimer*)timer;
-(void)startCycleTimer;
-(void)stopCycleTimer;
@end

@implementation BTC2Manager
@synthesize central;
@synthesize peripheral;
@synthesize managerState;

-(id)init{

    if ((self = [super init])){
        self.central = [[BTC2CentralDelegate alloc] init];
        self.peripheral = [[BTC2PeripheralDelegate alloc] init];
     
        BTC2ServiceProviderModel* provider = [[BTC2ServiceProviderModel alloc] init];
        provider.serviceName = @"someservice";
        provider.serviceUserID = @"imauser";
        
        self.peripheral.serviceProvider = provider;
        
        BTC2IdentificationModel* identity = [[BTC2IdentificationModel alloc] init];
        identity.pseudonym = @"HaxxorBot";
        identity.avatarID = @"stork";
        identity.avatarServiceName = @"robohash";
    }
    
    return self;
}


-(void)startCycleTimer{
    self.stateTimer = [NSTimer timerWithTimeInterval:10
                                              target:self
                                            selector:@selector(changeState:)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.stateTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopCycleTimer{
    if (self.stateTimer.isValid) {
        [self.stateTimer invalidate];
    }
}

-(void)startCycle{
    [self enterCentralMode];
    [self startCycleTimer];
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
    [self.peripheral cleanup];
    [self.central startScan];
}

-(void)enterPeripheralMode{
    DLog(@"enterPeripheralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralModeStarted object:nil];

    self.managerState = BTC2ManagerStatePeripheral;
    [self.central cleanup];
    [self.peripheral startAdvertising];
}

-(void)enterNeutralMode{
    DLog(@"enterNeutralMode");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNeutralModeStarted object:nil];

    [self stopCycleTimer];
    self.managerState = BTC2ManagerStateNeutral;
    [self.central cleanup];
    [self.peripheral cleanup];
}

@end
