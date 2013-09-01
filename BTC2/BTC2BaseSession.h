/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Joakim Fernstad
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

//
//  BTC2BaseSession.h
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import <Foundation/Foundation.h>
#import "BTC2Constants.h"
#import "BTC2UUIDs.h"
#import "BTC2WalletModel.h"
#import "BTC2IdentityModel.h"
#import "BTC2ServiceProviderModel.h"
#import <CoreBluetooth/CoreBluetooth.h>

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

-(void)addData:(NSData*)value forCharacteristic:(CBCharacteristic*)characteristic;

-(void)executeOnMainThread:(void (^)())block; // TODO: Move this to a more general place
-(void)postNotification:(NSString*)notificationName withDict:(NSDictionary*)dict;
-(void)handleJSON:(NSData*)jsonData forUUID:(CBUUID*)uuid;

@end
