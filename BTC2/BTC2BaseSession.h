//
//  BTC2BaseSession.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"

@class BTC2BaseSession;

// Delegates called on the main thread
@protocol BTC2DataUpdatedDelegate <NSObject>
-(void)btc2DidUpdateWalletProperty:(BTC2WalletPropertyEnum)property forSession:(BTC2BaseSession*)session;
-(void)btc2DidUpdateIdentityProperty:(BTC2IdentityPropertyEnum)property forSession:(BTC2BaseSession*)session;
-(void)btc2DidUpdateServiceProvider:(BTC2ServiceProviderPropertyEnum)property forSession:(BTC2BaseSession*)session;
@end

@interface BTC2BaseSession : NSObject
@property (nonatomic, strong) BTC2WalletModel* wallet;
@property (nonatomic, strong) BTC2IdentityModel* identity;
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;
@property (nonatomic, strong) id<BTC2DataUpdatedDelegate> delegate;
-(void)writeNotice:(NSString *)notice;
-(void)writePaymentRequest:(BTC2PaymentRequestModel*)paymentRequest;
@end
