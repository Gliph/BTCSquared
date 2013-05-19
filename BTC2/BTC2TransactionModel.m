//
//  BTC2TransactionModel.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2TransactionModel.h"

@implementation BTC2TransactionModel
-(bool)sentToMe {
    return [self.amount integerValue] > 0;
}
@end
