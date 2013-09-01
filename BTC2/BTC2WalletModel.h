//
//  BTC2WalletModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/25/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTC2PaymentRequestModel.h"

typedef enum BTC2WalletPropertyEnum {
    BTC2WalletPropertyWalletAddress = 0,
    BTC2WalletPropertyNotice,
    BTC2WalletPropertyPaymentRequest,
}BTC2WalletPropertyEnum;

@interface BTC2WalletModel : NSObject
@property (nonatomic, strong) NSString* walletAddress;
@property (nonatomic, strong) NSString* notice;
@property (nonatomic, strong) BTC2PaymentRequestModel* paymentRequest;

-(NSData*)walletAddresJSON;
-(NSData*)noticeJSON;
-(NSData*)paymentRequestJSON;
@end
