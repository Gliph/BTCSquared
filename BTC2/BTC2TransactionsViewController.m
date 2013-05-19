//
//  BTC2TransactionsViewController.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-18.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2TransactionsViewController.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2TransactionsViewController ()

@end

@implementation BTC2TransactionsViewController

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

@end
