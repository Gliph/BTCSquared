//
//  BTC2CircleLayout.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTC2CircleLayout : UICollectionViewLayout
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) CGFloat radius;
@end
