//
//  BTC2NewTransactionViewController.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-18.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2NewTransactionViewController.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

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
- (IBAction)sendBitcoin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString* BTCString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.equivalentValueLabel.text = [NSString stringWithFormat:@"≈ $%f", [BTCString floatValue] * 123.0];

    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}
@end
