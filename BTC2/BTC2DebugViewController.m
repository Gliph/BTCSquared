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
@property (nonatomic, strong) BTC2Manager* BTC2Manager;
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
    
    self.BTC2Manager = [[BTC2Manager alloc] init];

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
    [self.BTC2Manager enterCentralMode];
}
- (IBAction)startPeripheralMode:(id)sender {
    [self.BTC2Manager enterPeripheralMode];
}
- (IBAction)start:(id)sender {
    [self.BTC2Manager startCycle];
}
- (IBAction)stop:(id)sender {
    DLog(@" STOP (Neutral mode)!");
    [self.BTC2Manager enterNeutralMode];
}
- (IBAction)connectPeripheral:(id)sender {
    if (self.BTC2Manager.central.foundPeripheral) {
        [self.BTC2Manager.central.centralManager connectPeripheral:self.BTC2Manager.central.foundPeripheral options:nil];
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
