//
//  BTC2BaseSession.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "BTC2IdentificationModel.h"
#include "BTC2ServiceProviderModel.h"

@interface BTC2BaseSession : NSObject
@property (nonatomic, strong) NSString* walletAddress;
@property (nonatomic, strong) BTC2IdentificationModel* avatar;
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;
-(void)writeNotice:(NSString*)notice;
@end
