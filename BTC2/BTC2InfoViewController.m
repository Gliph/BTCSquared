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
//  BTC2InfoViewController.m
//  BTC2
//
//  Created by Joakim on 2013-09-14.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2InfoViewController.h"
#import "BTC2AvatarView.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2InfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pseudonymLabel;
@property (weak, nonatomic) IBOutlet UILabel *avatarServiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *avatarIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceProviderLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceProviderUserIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentRequestLabel;
@property (weak, nonatomic) IBOutlet BTC2AvatarView *avatarImage;

@end

@implementation BTC2InfoViewController

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
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.pseudonymLabel.text        = self.session.identity.pseudonym;
    self.avatarIDLabel.text         = self.session.identity.avatarID;
    self.avatarServiceLabel.text    = self.session.identity.avatarServiceName;
    
    self.walletAddressLabel.text    = self.session.wallet.walletAddress;
    self.noticeLabel.text           = self.session.wallet.notice;
    self.paymentRequestLabel.text   = [self.session.wallet.paymentRequest description];
    
    self.serviceProviderLabel.text       = self.session.serviceProvider.serviceName;
    self.serviceProviderUserIDLabel.text = self.session.serviceProvider.serviceUserID;

    if (self.session.identity.avatarImage) {
        self.avatarImage.imageView.image = self.session.identity.avatarImage;
    }else{
        // TODO: Grab image
    }

}

@end
