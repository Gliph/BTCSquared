//
//  BTC2AttachWalletViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/19/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2AttachWalletViewController.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2AttachWalletViewController ()

@end

@implementation BTC2AttachWalletViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor btc2RandomColor].CGColor,
                        (id)[UIColor btc2RandomColor].CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)attachWallet:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
