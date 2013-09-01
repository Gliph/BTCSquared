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
//  BTC2CentralSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2CentralSession.h"
#import "BTC2PeripheralManager.h"
#import "BTC2WriteQueue.h"

@implementation BTC2CentralSession

-(void)writeNotice:(NSString *)notice{
    CBMutableCharacteristic* noticeCharacteristic = nil;
    if (notice.length) {
        
        // Ok this is a bit awkward
        BTC2WalletModel* tmpModel = [[BTC2WalletModel alloc] init];
        tmpModel.notice = notice;
        
        NSUInteger idx = [[self.peripheral walletService].characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic* c, NSUInteger idx, BOOL *stop) {
                            if ([c.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeNotificationUUID]]) {
                                return YES;
                                *stop = YES;
                            }
                            return NO;
                        }];
        
        if (idx != NSNotFound) {
            noticeCharacteristic = [[self.peripheral walletService].characteristics objectAtIndex:idx];

            [self.peripheral enqueueData:[tmpModel noticeJSON]
                       forCharacteristic:noticeCharacteristic];
        }
    }
}

-(void)writePaymentRequest:(BTC2PaymentRequestModel *)paymentRequest{
    CBMutableCharacteristic* noticeCharacteristic = nil;
    NSData* paymentJsonData = [paymentRequest paymentRequestJSON];
    if (paymentJsonData.length) {
        NSUInteger idx = [[self.peripheral walletService].characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic* c, NSUInteger idx, BOOL *stop) {
            if ([c.UUID isEqual:[CBUUID UUIDWithString:kBTC2WalletPaymentNotificationUUID]]) {
                return YES;
                *stop = YES;
            }
            return NO;
        }];
        
        if (idx != NSNotFound) {
            noticeCharacteristic = [[self.peripheral walletService].characteristics objectAtIndex:idx];
            
            [self.peripheral enqueueData:paymentJsonData
                       forCharacteristic:noticeCharacteristic];
        }
    }
}

@end
