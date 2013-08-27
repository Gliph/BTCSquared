//
//  BTC2PaymentRequestModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/26/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTC2PaymentRequestModel : NSObject
@property (nonatomic, strong) NSNumber* amount;
@property (nonatomic, strong) NSString* currency; // Currency code; BTC, SAT (satoshi), USD, EUR, etc
+(BTC2PaymentRequestModel*)requestAmount:(NSNumber*)amount withCurrency:(NSString*)currencyCode;
-(NSData*)paymentRequestJSON;
@end
