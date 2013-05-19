//
//  BTC2NameViewController.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-18.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2NameViewController.h"
#import "UIColor+BTC2Extensions.h"
#import "BTC2RobotView.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2NameViewController ()
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet BTC2RobotView *roboView;
@end

@implementation BTC2NameViewController

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
    
    self.roboView.roboName = @"HaxxorRobot";
    self.roboView.roboSize = self.roboView.bounds.size;
    [self.roboView retrieveRobot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateName:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
