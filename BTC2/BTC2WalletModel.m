//
//  BTC2WalletModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/25/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2WalletModel.h"
#import "BTC2Constants.h"
#import "NSDictionary+BTC2Extensions.h"

@implementation BTC2WalletModel

-(NSData*)walletAddresJSON{
    NSData* encodedData = nil;
    
    if (self.walletAddress.length) {
        encodedData = [@{kBTC2WalletAddressKey: self.walletAddress} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSData*)noticeJSON{
    NSData* encodedData = nil;
    
    if (self.notice.length) {
        encodedData = [@{kBTC2WalletNoticeKey: self.notice} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSData*)paymentRequestJSON{
    return [self.paymentRequest paymentRequestJSON];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"Wallet: %@. Notice: %@. Payment Req: %@.", self.walletAddress, self.notice, self.paymentRequest];
}

@end
