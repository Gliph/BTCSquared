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
//  BTC2NewTransactionViewController.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-18.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2NewTransactionViewController.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2NewTransactionViewController ()
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITextField *btcInputField;
@property (nonatomic, strong) IBOutlet UILabel *equivalentValueLabel;
@property (nonatomic, strong) IBOutlet UIButton *createTransactionButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString* sendText = [NSString stringWithFormat:@"Send to %@", self.toSession.identity.pseudonym];
    [self.sendButton setTitle:sendText forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendBitcoin:(id)sender {
    
    if (self.toSession) {
        CGFloat value = [self.btcInputField.text floatValue];
        NSString* notice = [NSString stringWithFormat:@"%@ sent you %2.f BTC [%2.f USD].", self.fromSession.identity.pseudonym, value, value * 120.0];
        [self.toSession writeNotice:notice];
    }
    
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
