//
//  BTC2ViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2DebugViewController.h"
#import "BTC2Manager.h"
#import "BTC2Events.h"

@interface BTC2DebugViewController ()
@property (nonatomic, strong) BTC2Manager* btc2Manager;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
-(void)modeNotification:(NSNotification*)not;
@end

@implementation BTC2DebugViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeNotification:) name:kNeutralModeStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeNotification:) name:kCentralModeStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeNotification:) name:kPeripheralModeStarted object:nil];
    
    self.btc2Manager = [[BTC2Manager alloc] init];
    
    // Peripheral side
    BTC2WalletModel* walletModel            = [[BTC2WalletModel alloc] init];
    BTC2IdentityModel* idModel              = [[BTC2IdentityModel alloc] init];
    BTC2ServiceProviderModel* providerModel = [[BTC2ServiceProviderModel alloc] init];
    
    walletModel.walletAddress       = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations!
    walletModel.paymentRequest      = [BTC2PaymentRequestModel requestAmount:@(1000)  withCurrency:@"BTC"];
    
    idModel.pseudonym               = @"HaxxorBot";
    idModel.avatarID                = @"haxxorbot";
    idModel.avatarServiceName       = @"robohash";
    idModel.avatarURL               = [NSURL URLWithString:@"http://robohash.org/haxxorbot.png"];
    
    providerModel.serviceName       = @"gliph";
    providerModel.serviceUserID     = @"di.di.di";
    
    self.btc2Manager.wallet          = walletModel;
    self.btc2Manager.identity        = idModel;
    self.btc2Manager.serviceProvider = providerModel;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startCentral:(id)sender {
    [self.btc2Manager enterCentralMode];
}
- (IBAction)startPeripheralMode:(id)sender {
    [self.btc2Manager enterPeripheralMode];
}
- (IBAction)start:(id)sender {
}
- (IBAction)stop:(id)sender {
    DLog(@" STOP (Neutral mode)!");
    [self.btc2Manager enterNeutralMode];
}
- (IBAction)connectPeripheral:(id)sender {
    if (self.btc2Manager.central.foundPeripheral) {
        [self.btc2Manager.central.centralManager connectPeripheral:self.btc2Manager.central.foundPeripheral options:nil];
    }
}

-(void)modeNotification:(NSNotification*)not{

    UIColor* background = [UIColor whiteColor];
    
    DLog(@"modeNotification: %@", not);
    
    if ([not.name caseInsensitiveCompare:kCentralModeStarted] == NSOrderedSame) {
        background = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
    }
//    if ([not.name caseInsensitiveCompare:kNeutralModeStarted] == NSOrderedSame) {
//        background = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:1];
//    }
    if ([not.name caseInsensitiveCompare:kPeripheralModeStarted] == NSOrderedSame) {
        background = [UIColor colorWithRed:0.1 green:0.1 blue:0.5 alpha:1];
    }

    self.view.backgroundColor = background;
    
}


@end
