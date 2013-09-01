//
//  BTC2CentralSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
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
