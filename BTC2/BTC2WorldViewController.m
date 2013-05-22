//
//  BTC2WorldViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2WorldViewController.h"
#import "BTC2CircleLayout.h"
#import "BTC2RobotViewCell.h"

#import "BTC2NameViewController.h"
#import "BTC2NewTransactionViewController.h"
#import "BTC2AttachWalletViewController.h"
#import "BTC2TransactionsViewController.h"

#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2WorldViewController ()
-(void)peripheralAdded:(NSNotification*)not;
-(void)setupContextMenu;

-(void)didAttachWallet:(NSNotification*)not;

// Menu actions
-(void)transactions:(id)sender;
-(void)attachWallet:(id)sender;
-(void)changeName:(id)sender;
-(void)sendBTC:(id)sender;
-(void)requestBTC:(id)sender;
-(void)showFriends:(id)sender;
@end

@implementation BTC2WorldViewController

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

    UIView* background = [[UIView alloc] initWithFrame:self.view.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor btc2RandomColor].CGColor,
                        (id)[UIColor btc2RandomColor].CGColor];
    [background.layer insertSublayer:gradient atIndex:0];
    
    self.collectionView.backgroundView = background;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peripheralAdded:)
                                                 name:kPeripheralAddedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAttachWallet:)
                                                 name:kWalletAddedNotification
                                               object:nil];
    
    int64_t delta = (int64_t)(1.0e9 * 5);
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
//        [self.peripherals addObject:@"Bito"];
//        [self.peripherals addObject:@"Coino"];
//        [self.peripherals addObject:@"Satoshio"];
//        [self.collectionView reloadData];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:@"FakeWallet" forKey:kUserWalletKey];
//        [self setupContextMenu];
//        
//        // Debug
//        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserWalletKey];
//    });

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.collectionView.scrollEnabled = NO;
    
    BTC2CircleLayout* layout = (BTC2CircleLayout*)self.collectionView.collectionViewLayout;
    layout.cellSize = CGSizeMake(100, 120);
    layout.radius   = 130;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setupContextMenu];
}

-(void)setupContextMenu{
    UIMenuController* controller = [UIMenuController sharedMenuController];
    NSMutableArray* menuOptions = [NSMutableArray arrayWithCapacity:3];
    UIMenuItem* anItem = nil;
    
    // Wallet attached
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserWalletKey]) {
//        anItem = [[UIMenuItem alloc] initWithTitle:@"Transactions" action:@selector(transactions:)];
//        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Change name" action:@selector(changeName:)];
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Attach wallet" action:@selector(attachWallet:)];
        [menuOptions addObject:anItem];

        anItem = [[UIMenuItem alloc] initWithTitle:@"Send BTC" action:@selector(sendBTC:)];
        [menuOptions addObject:anItem];
        anItem = [[UIMenuItem alloc] initWithTitle:@"Request BTC" action:@selector(requestBTC:)];
        [menuOptions addObject:anItem];
    
//    }else{ // No wallet attached
        anItem = [[UIMenuItem alloc] initWithTitle:@"BTC2 Users" action:@selector(showFriends:)];
        [menuOptions addObject:anItem];
//        anItem = [[UIMenuItem alloc] initWithTitle:@"Change name" action:@selector(changeName:)];
//        [menuOptions addObject:anItem];
//    }
    
    controller.menuItems = menuOptions;
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
    BTC2RobotViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RoboCell" forIndexPath:indexPath];
    
    cell.roboView.roboName = [self.peripherals objectAtIndex:indexPath.row];
    cell.roboView.roboSize = CGSizeMake(100, 100);
    
    if (!cell.roboView.hasRobot) {
        [cell.roboView retrieveRobot];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    BTC2RobotViewCell* cell = (BTC2RobotViewCell*)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];

}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    BOOL canPerformAction = NO;
    BOOL hasWallet = ([[NSUserDefaults standardUserDefaults] objectForKey:kUserWalletKey] != nil);
    
    if (action == @selector(attachWallet:) && indexPath.row == 0 && !hasWallet) {
        canPerformAction = YES;
    }
    if (action == @selector(transactions:) && indexPath.row == 0) {
        canPerformAction = YES;
    }
    if (action == @selector(changeName:) && indexPath.row == 0) {
        canPerformAction = YES;
    }
    if (action == @selector(sendBTC:) && indexPath.row > 0 && hasWallet) {
        canPerformAction = YES;
    }
    if (action == @selector(requestBTC:) && indexPath.row > 0 && hasWallet) {
        canPerformAction = YES;
    }
    if (action == @selector(showFriends:) && indexPath.row > 0 && hasWallet) {
        canPerformAction = YES;
    }

    // Debug
    if (canPerformAction) {
        DLog(@"collectionView:canPerformAction:forItemAtIndexPath %s | %@", sel_getName(action), indexPath);
    }else{
        DLog(@" REJECTED %s | %@", sel_getName(action), indexPath);
    }
    
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldShowMenu = NO;

    BOOL hasWallet = ([[NSUserDefaults standardUserDefaults] objectForKey:kUserWalletKey] != nil);

    shouldShowMenu = (hasWallet && indexPath.row > 0) || !indexPath.row;

    DLog(@"shouldShowMenuForItemAtIndexPath: %@ %@", shouldShowMenu?@"Yes":@"No", indexPath);

    return shouldShowMenu;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    DLog(@"performAction: %s", sel_getName(action));
    
    
}

#pragma mark - 

-(void)didAttachWallet:(NSNotification*)not{

}


-(void)peripheralAdded:(NSNotification*)not{
    DLog(@"peripheralAdded");
    if (!self.peripherals.count) {
        self.peripherals = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    [self.peripherals addObject:not.object];
    //    self.peripherals = [NSArray arrayWithArray:newArray];
    
    //    DLog(@"%@", self.peripherals);
    
    [self.collectionView reloadData];
    //    NSIndexPath* newPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:0];
    //    [self.collectionView insertItemsAtIndexPaths:@[newPath]];
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

-(void)showFriends:(id)sender{

    if (self.peripherals.count < 2) {
        [self.peripherals addObject:@"Bito"];
        [self.peripherals addObject:@"Coino"];
        [self.peripherals addObject:@"Satoshio"];
        [self.collectionView reloadData];

        [[NSUserDefaults standardUserDefaults] setObject:@"FakeWallet" forKey:kUserWalletKey];
        [self setupContextMenu];
    }

}
@end
