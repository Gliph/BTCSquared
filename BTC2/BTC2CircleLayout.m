//
//  BTC2CircleLayout.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2CircleLayout.h"

@implementation BTC2CircleLayout

#pragma mark - Overrides

- (void)prepareLayout{
    [super prepareLayout];

    self.count = [[self collectionView] numberOfItemsInSection:0];
//    self.cellSize = CGSizeMake(50, 50);
//    self.radius = 100;
}

- (CGSize)collectionViewContentSize{
    return CGSizeMake(320, 480); // UIScreen size
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i=0; i< self.count; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    DLog(@"Laying out %d", indexPath.row);
    
    CGSize contentSize = [self collectionViewContentSize];
    CGPoint newCenter = CGPointMake(contentSize.width/2.0, contentSize.height/2.0);
    CGFloat angle = 0;
    
    if (indexPath.row > 0) {
        angle = indexPath.row / (CGFloat)(self.count-1) * 2 * M_PI + M_PI/4;
        newCenter = CGPointMake(contentSize.width/2.0 - self.radius * cos(angle), contentSize.height/2.0 - self.radius * sin(angle));
        DLog(@"Angle %f", angle);
    }
    
    att.center = newCenter;
    att.size = self.cellSize;
    return att;
}

-(UICollectionViewLayoutAttributes *) initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
	CGSize contentSize = [self collectionViewContentSize];
    CGPoint newCenter = CGPointMake(contentSize.width/2.0, contentSize.height/2.0);
    att.alpha = 1.0;
    att.center = newCenter;
return att;
}


//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
//    
//}
//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
//    
//}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath{
//
//}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}


@end
