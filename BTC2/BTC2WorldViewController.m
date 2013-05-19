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
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface BTC2WorldViewController ()
-(void)peripheralAdded:(NSNotification*)not;
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
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.collectionView.scrollEnabled = NO;
    
    BTC2CircleLayout* layout = (BTC2CircleLayout*)self.collectionView.collectionViewLayout;
    layout.cellSize = CGSizeMake(100, 120);
    layout.radius   = 130;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)peripheralAdded:(NSNotification*)not{
    NSLog(@"peripheralAdded");
    if (!self.peripherals.count) {
        self.peripherals = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    [self.peripherals addObject:not.object];
//    self.peripherals = [NSArray arrayWithArray:newArray];
    
//    NSLog(@"%@", self.peripherals);
    
    [self.collectionView reloadData];
//    NSIndexPath* newPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:0];
//    [self.collectionView insertItemsAtIndexPaths:@[newPath]];
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


@end
