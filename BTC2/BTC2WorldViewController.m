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

@interface BTC2WorldViewController ()

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

//    [self.collectionView registerClass:[BTC2RobotViewCell class] forCellWithReuseIdentifier:@"RoboCell"];
	// Do any additional setup after loading the view.

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    BTC2CircleLayout* layout = (BTC2CircleLayout*)self.collectionView.collectionViewLayout;
    layout.cellSize = CGSizeMake(100, 100);
    layout.radius   = 130;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BTC2RobotViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RoboCell" forIndexPath:indexPath];

    cell.roboView.roboName = [NSString stringWithFormat:@"%d", indexPath.row];
    cell.roboView.roboSize = CGSizeMake(100, 100);
    
    [cell.roboView retrieveRobot];
    
    return cell;
}


@end
