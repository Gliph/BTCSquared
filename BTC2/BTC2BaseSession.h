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
@protocol BTC2ReceiveDataDelegate <NSObject>
-(void)didReceiveWalletAddress:(NSString*)wallet fromSession:(BTC2BaseSession*)session;
-(void)didReceiveNotice:(NSString*)notice fromSession:(BTC2BaseSession*)session;
-(void)didReceivePaymentRequest:(BTC2PaymentRequestModel*)payment fromSession:(BTC2BaseSession*)session;
@end

@interface BTC2BaseSession : NSObject
@property (nonatomic, strong) BTC2WalletModel* wallet;
@property (nonatomic, strong) BTC2IdentityModel* identity;
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;
@property (nonatomic, strong) id<BTC2ReceiveDataDelegate> delegate;
-(void)writeNotice:(NSString *)notice;
-(void)writePaymentRequest:(BTC2PaymentRequestModel*)paymentRequest;
@end
