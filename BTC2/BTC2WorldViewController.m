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
//  BTC2WorldViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2WorldViewController.h"
#import "BTC2CircleLayout.h"
#import "BTC2AvatarViewCell.h"

#import "BTC2Manager.h"
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"
#import "BTC2Constants.h"
#import "BTC2Events.h"
#import "BTC2DeviceSession.h"

#import "BTC2NameViewController.h"
#import "BTC2NewTransactionViewController.h"
#import "BTC2AttachWalletViewController.h"
#import "BTC2TransactionsViewController.h"

#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2WorldViewController ()
@property (nonatomic, assign, getter = isBtc2Enabled) BOOL btc2Enabled;
@property (nonatomic, strong) BTC2Manager* btc2Manager;
@property (nonatomic, strong) BTC2BaseSession* localSession;
@property (nonatomic, weak) BTC2DeviceSession* tappedSession;

-(void)peripheralAdded:(NSNotification*)not;

-(void)didAttachWallet:(NSNotification*)not;

// Menu actions
-(void)transactions:(id)sender;
-(void)attachWallet:(id)sender;
-(void)changeName:(id)sender;
-(void)sendBTC:(id)sender;
-(void)requestBTC:(id)sender;
-(void)enableBTC2:(id)sender;
-(void)connectSession:(id)sender;
-(void)disconnectSession:(id)sender;
@end

@implementation BTC2WorldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView* background = [[UIView alloc] initWithFrame:self.view.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor btc2RandomColor].CGColor,
                        (id)[UIColor btc2RandomColor].CGColor];
    [background.layer insertSublayer:gradient atIndex:0];
    
    self.collectionView.backgroundView = background;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peripheralAdded:)
                                                 name:kBTC2DidDiscoverPeripheralNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAttachWallet:)
                                                 name:kWalletAddedNotification
                                               object:nil];
    
    self.btc2Enabled = NO;
    
    self.btc2Manager  = [[BTC2Manager alloc] init];
    self.localSession = [[BTC2BaseSession alloc] init];
    
    BTC2WalletModel* walletModel            = [[BTC2WalletModel alloc] init];
    BTC2IdentityModel* idModel              = [[BTC2IdentityModel alloc] init];
    BTC2ServiceProviderModel* providerModel = [[BTC2ServiceProviderModel alloc] init];
    
    walletModel.walletAddress       = @"1DdeszrHwfCFA9yNdoTAotSEgNpaVmv2DP"; // Donations!
    
    idModel.pseudonym               = @"FloBot";
    idModel.avatarID                = @"flo";
    idModel.avatarServiceName       = @"robohash";
    idModel.avatarURL               = [NSURL URLWithString:@"http://robohash.org/flobot.png"];
    
    providerModel.serviceName       = @"gliph";
    providerModel.serviceUserID     = @"di.di.di";
    
    self.localSession.wallet             = walletModel;
    self.localSession.identity           = idModel;
    self.localSession.serviceProvider    = providerModel;
    
    self.peripherals = [[NSMutableArray alloc] initWithCapacity:1];
    [self.peripherals addObject:self.localSession];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.collectionView.scrollEnabled = NO;
    
    BTC2CircleLayout* layout = (BTC2CircleLayout*)self.collectionView.collectionViewLayout;
    layout.cellSize = CGSizeMake(100, 120);
    layout.radius   = 130;

    [self.collectionView reloadData];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)setupContextMenuForFriends:(BOOL)yesForFriends andConnectionState:(BOOL)connected{
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    
    NSMutableArray* menuOptions = [NSMutableArray arrayWithCapacity:3];
    UIMenuItem* anItem = nil;

    if (yesForFriends) {
        if (!connected) {
            anItem = [[UIMenuItem alloc] initWithTitle:@"Connect" action:@selector(connectSession:)];
            [menuOptions addObject:anItem];
        }else{
            anItem = [[UIMenuItem alloc] initWithTitle:@"Disconnect" action:@selector(disconnectSession:)];
            [menuOptions addObject:anItem];
        }
        anItem = [[UIMenuItem alloc] initWithTitle:@"Send BTC" action:@selector(sendBTC:)];
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Request BTC" action:@selector(requestBTC:)];
        [menuOptions addObject:anItem];
    }else{
        
        if (!self.isBtc2Enabled) {
            anItem = [[UIMenuItem alloc] initWithTitle:@"Enable BTC2" action:@selector(enableBTC2:)];
        }else{
            anItem = [[UIMenuItem alloc] initWithTitle:@"Disable BTC2" action:@selector(disableBTC2:)];
        }
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Attach wallet" action:@selector(attachWallet:)];
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Pseudonym" action:@selector(changeName:)];
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Transactions" action:@selector(transactions:)];
        [menuOptions addObject:anItem];
    }
    
    menuController.menuItems = menuOptions;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.peripherals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BTC2AvatarViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RoboCell" forIndexPath:indexPath];
    
    BTC2BaseSession* session = [self.peripherals objectAtIndex:indexPath.row];;
    
    cell.avatarView.identity = session.identity;
    
    if (!cell.avatarView.hasAvatar) {
        [cell.avatarView retrieveAvatar];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    BTC2AvatarViewCell* cell = (BTC2AvatarViewCell*)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    self.tappedSession = [self.peripherals objectAtIndex:indexPath.row];
    
    // Tapped me
    if (indexPath.row == 0) {
        [self setupContextMenuForFriends:NO andConnectionState:NO];
    }else{
        [self setupContextMenuForFriends:YES andConnectionState:self.tappedSession.peripheral.isConnected];
    }
    
    [[UIMenuController sharedMenuController] setTargetRect:cell.frame inView:collectionView];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];

}

#pragma mark -

-(void)didAttachWallet:(NSNotification*)not{

}


-(void)peripheralAdded:(NSNotification*)not{
    DLog(@"peripheralAdded");
    
    BTC2BaseSession* session = [not.object objectForKey:kBTC2DeviceSessionKey];
    
    session.delegate = self;
    
    [self.peripherals addObject:session];
    [self.collectionView reloadData];
}


#pragma mark - Menu options

// Menu actions
-(void)transactions:(id)sender{
    DLog(@"-> transactions");

    BTC2TransactionsViewController* transactions = [self.storyboard instantiateViewControllerWithIdentifier:@"BTC2TransactionsViewController"];
    
    [self presentViewController:transactions animated:YES completion:nil];
    
}
-(void)attachWallet:(id)sender{
    DLog(@"-> attachWallet");

    BTC2AttachWalletViewController* attachWallet = [self.storyboard instantiateViewControllerWithIdentifier:@"BTC2AttachWalletViewController"];

    [self presentViewController:attachWallet animated:YES completion:nil];
}
-(void)changeName:(id)sender{
    DLog(@"-> changeName");
    
    BTC2NameViewController* nameChangeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BTC2NameViewController"];
    
    [self presentViewController:nameChangeViewController animated:YES completion:^{
        DLog(@"Closed modal");
    }];
    
}

-(void)sendBTC:(id)sender{
    DLog(@"-> sendBTC");
    BTC2NewTransactionViewController* transactionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BTC2NewTransactionViewController"];
    
    [self presentViewController:transactionViewController animated:YES completion:nil];
    
}
-(void)requestBTC:(id)sender{
    DLog(@"-> requestBTC");
}

-(void)enableBTC2:(id)sender{
    if (!self.isBtc2Enabled) {
        
        // Peripheral side
        self.btc2Manager.wallet          = self.localSession.wallet;
        self.btc2Manager.identity        = self.localSession.identity;
        self.btc2Manager.serviceProvider = self.localSession.serviceProvider;

        [self.btc2Manager enterCentralMode];
        [self.btc2Manager enterPeripheralMode];
        
        self.btc2Enabled = YES;
    }
}
-(void)disableBTC2:(id)sender{
    [self.btc2Manager enterNeutralMode];
    self.btc2Enabled = NO;
    
    self.peripherals = [NSMutableArray arrayWithCapacity:1];
    [self.peripherals addObject:self.localSession];
    [self.collectionView reloadData];
}

-(void)connectSession:(id)sender{
    if (self.tappedSession) {
        [self.tappedSession connect];
    }
}

-(void)disconnectSession:(id)sender{
    if (self.tappedSession) {
        [self.tappedSession disconnect];
    }
}

#pragma mark - BTC2DataUpdatedDelegate - Debug only, the manager shouldn't really be a delegate

-(void)btc2DidUpdateWalletProperty:(BTC2WalletPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);
    
    switch (property) {
        case BTC2WalletPropertyWalletAddress:
            DLog(@"%@", session.wallet.walletAddress);
            break;
        case BTC2WalletPropertyNotice:
            DLog(@"%@", session.wallet.notice);
            break;
        case BTC2WalletPropertyPaymentRequest:
            DLog(@"%@", [session.wallet.paymentRequest description]);
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateIdentityProperty:(BTC2IdentityPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);
    
    switch (property) {
        case BTC2IdentityPropertyPseudonym:
            DLog(@"%@", session.identity.pseudonym);
            [self.collectionView reloadData];
            break;
        case BTC2IdentityPropertyAvatarServiceName:
            DLog(@"%@", session.identity.avatarServiceName);
            [self.collectionView reloadData];
            break;
        case BTC2IdentityPropertyAvatarID:
            DLog(@"%@", session.identity.avatarID);
            [self.collectionView reloadData];
            break;
        case BTC2IdentityPropertyAvatarURL:
            DLog(@"%@", session.identity.avatarURL);
            break;
        default:
            break;
    }
}

-(void)btc2DidUpdateServiceProvider:(BTC2ServiceProviderPropertyEnum)property forSession:(BTC2BaseSession *)session{
    DLog(@"Updated property %d ", property);
    
    switch (property) {
        case BTC2ServiceProviderPropertyServiceName:
            DLog(@"%@", session.serviceProvider.serviceName);
            break;
        case BTC2ServiceProviderPropertyServiceUserID:
            DLog(@"%@", session.serviceProvider.serviceUserID);
            break;
        default:
            break;
    }
}

@end
