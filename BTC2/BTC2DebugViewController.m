//
//  BTC2ViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2DebugViewController.h"
#import "BTC2Manager.h"

@interface BTC2DebugViewController ()
@property (nonatomic, strong) BTC2Manager* BTC2Manager;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
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
- (IBAction)start:(id)sender {
    self.BTC2Manager = [[BTC2Manager alloc] init];

    
}
- (IBAction)stop:(id)sender {
    NSLog(@" STOP (Neutral mode)!");
    [self.BTC2Manager enterNeutralMode];
}

-(void)modeNotification:(NSNotification*)not{

    UIColor* background = [UIColor whiteColor];
    
    NSLog(@"modeNotification: %@", not);
    
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
