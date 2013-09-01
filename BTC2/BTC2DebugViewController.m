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
//  BTC2ViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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

- (IBAction)requestBtc:(id)sender {
    if (self.btc2Manager.connectedSession) {
        [self.btc2Manager.connectedSession writePaymentRequest:[BTC2PaymentRequestModel requestAmount:@(3.14) withCurrency:@"btc"]];
    }
}

- (IBAction)sendNotice:(id)sender {
    if (self.btc2Manager.connectedSession) {
        [self.btc2Manager.connectedSession writeNotice:@"Thanks dude. "];
    }
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
