//
//  BTC2PaymentRequestModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/26/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2PaymentRequestModel.h"
#import "BTC2Constants.h"
#import "NSDictionary+BTC2Extensions.h"

@implementation BTC2PaymentRequestModel

+(BTC2PaymentRequestModel*)requestAmount:(NSNumber*)amount withCurrency:(NSString*)currencyCode{
    BTC2PaymentRequestModel* model = [[BTC2PaymentRequestModel alloc] init];
    model.amount = amount;
    model.currency = currencyCode;
    return model;
}

-(NSData*)paymentRequestJSON{
    NSData* encodedData = nil;
    
    if (self.amount && self.currency.length) {
        encodedData = [@{kBTC2WalletPaymentReqAmountKey: self.amount, kBTC2WalletPaymentCurrencyKey: self.currency} btc2RenderedJSON];
    }
    
    return encodedData;
}

@end
