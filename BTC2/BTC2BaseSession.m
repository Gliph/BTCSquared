//
//  BTC2BaseSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2BaseSession.h"

@implementation BTC2BaseSession
@synthesize wallet = m_wallet;
@synthesize identity = m_identity;
@synthesize serviceProvider = m_serviceProvider;

#pragma mark - Defaults

-(void)writeNotice:(NSString*)notice{
    DLog(@"Not implemented.");
}
-(void)writePaymentRequest:(BTC2PaymentRequestModel*)paymentRequest{
    DLog(@"Not implemented.");
}

#pragma mark - Lazy Getters

-(BTC2WalletModel*)wallet{
    if (!m_wallet){
        m_wallet = [[BTC2WalletModel alloc] init];
    }
    return m_wallet;
}

-(BTC2IdentityModel*)identity{
    if (!m_identity){
        m_identity = [[BTC2IdentityModel alloc] init];
    }
    return m_identity;
}

-(BTC2ServiceProviderModel*)serviceProvider{
    if (!m_serviceProvider){
        m_serviceProvider = [[BTC2ServiceProviderModel alloc] init];
    }
    return m_serviceProvider;
}

@end
