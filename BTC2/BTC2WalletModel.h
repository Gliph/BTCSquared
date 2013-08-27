//
//  BTC2WalletModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/25/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2PaymentRequestModel.h"

@interface BTC2WalletModel : NSObject
@property (nonatomic, retain) NSString* walletAddress;
@property (nonatomic, retain) NSString* notice;
@property (nonatomic, retain) BTC2PaymentRequestModel* paymentRequest;

-(NSData*)walletAddresJSON;
-(NSData*)noticeJSON;
-(NSData*)paymentRequestJSON;
@end
