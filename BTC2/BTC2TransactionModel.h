//
//  BTC2TransactionModel.h
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTC2TransactionModel : NSObject
@property (nonatomic, strong) NSString* amount;

-(bool)sentToMe;
@end
