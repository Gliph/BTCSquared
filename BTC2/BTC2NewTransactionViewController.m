//
//  BTC2NewTransactionViewController.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-18.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2NewTransactionViewController.h"

@interface BTC2NewTransactionViewController ()
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITextField *btcInputField;
@property (nonatomic, strong) IBOutlet UILabel *equivalentValueLabel;
@property (nonatomic, strong) IBOutlet UIButton *createTransactionButton;
@end

@implementation BTC2NewTransactionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
