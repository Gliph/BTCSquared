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
//  BTC2BaseSession.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2BaseSession.h"
#import "NSObject+BTC2Extensions.h"

@interface BTC2BaseSession ()
@property (nonatomic, strong) NSMutableDictionary* buffers;
-(NSInteger)jsonDataSize:(NSData*)buffer;
@end

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



#pragma mark - Methods

-(NSInteger)jsonDataSize:(NSData*)buffer{
    NSString* value = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    
    // Format: {"size":xxx,
    // Read: xxx
    
    NSInteger sizeValue = -1;
    NSScanner* sizeScanner = [NSScanner scannerWithString:value];
    [sizeScanner setCharactersToBeSkipped:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    [sizeScanner scanInteger:&sizeValue];

    return sizeValue;
}

-(void)addData:(NSData*)data forCharacteristic:(CBCharacteristic*)characteristic{
    NSMutableData* buffer = nil;
    NSInteger jsonObjectSize = -1;
    
    if (data.length && characteristic) {
        
        if (!self.buffers) {
            self.buffers = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        
        buffer = [self.buffers objectForKey:characteristic.UUID];

        if (!buffer) {
            buffer = [NSMutableData dataWithCapacity:data.length];
            [self.buffers setObject:buffer forKey:characteristic.UUID];
        }
        
        [buffer appendData:data];

        jsonObjectSize = [self jsonDataSize:buffer];
        
        // Invalid object if no size tag or buffer is bigger than what the size said
        if (jsonObjectSize == -1 ||
            buffer.length > jsonObjectSize){
            [self.buffers removeObjectForKey:characteristic.UUID];
            return;
        }

        NSError* error = nil;
        NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:buffer options:0 error:&error];

        if (!error && jsonObject) {
            // We have a fully qualified jsonObject. Should be a dictionary.
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                // Woho, let delegate handle full buffer, then remove buffer
                [self handleJSON:buffer forUUID:characteristic.UUID];
                [self.buffers removeObjectForKey:characteristic.UUID]; // Clear buffer
            }
        }
    }
}

-(void)handleJSON:(NSData*)jsonData forUUID:(CBUUID*)uuid{
    
    NSError* error = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (!error) {
        if ([jsonDict isKindOfClass:[NSDictionary class]]) {
            
            // Wallet service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletAddressReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletAddressWriteUUID]]) {
                self.wallet.walletAddress = [jsonDict objectForKey:kBTC2WalletAddressKey];
                
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyWalletAddress forSession:self];
                    }];
                }
            }

            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletPaymentNotificationUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletPaymentWriteUUID]]) {
                self.wallet.paymentRequest = [BTC2PaymentRequestModel requestAmount:[jsonDict objectForKey:kBTC2WalletPaymentReqAmountKey]
                                                                       withCurrency:[jsonDict objectForKey:kBTC2WalletPaymentCurrencyKey]];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyPaymentRequest forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeNotificationUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2WalletNoticeWriteUUID]]) {
                self.wallet.notice = [jsonDict objectForKey:kBTC2WalletNoticeKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateWalletProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateWalletProperty:BTC2WalletPropertyNotice forSession:self];
                    }];
                }
            }
            
            // Identity service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDPseudonymReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2IDPseudonymWriteUUID]]) {
                self.identity.pseudonym = [jsonDict objectForKey:kBTC2IdentificationPseudonymKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyPseudonym forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarServiceReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarServiceWriteUUID]]) {
                self.identity.avatarServiceName = [jsonDict objectForKey:kBTC2IdentificationAvatarServiceKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarServiceName forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarIDReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarIDWriteUUID]]) {
                self.identity.avatarID = [jsonDict objectForKey:kBTC2IdentificationAvatarIDKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarID forSession:self];
                    }];
                }
            }
            
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarURLReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2IDAvatarURLWriteUUID]]) {
                self.identity.avatarURL = [NSURL URLWithString:[jsonDict objectForKey:kBTC2IdentificationAvatarURLKey]];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateIdentityProperty:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateIdentityProperty:BTC2IdentityPropertyAvatarURL forSession:self];
                    }];
                }
            }
            
            // Service provider service
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderNameReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderNameWriteUUID]]) {
                self.serviceProvider.serviceName = [jsonDict objectForKey:kBTC2ServiceProviderNameKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateServiceProvider:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateServiceProvider:BTC2ServiceProviderPropertyServiceName forSession:self];
                    }];
                }
            }
            if ([uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDReadUUID]] ||
                [uuid isEqual:[CBUUID UUIDWithString:kBTC2ServiceProviderUserIDWriteUUID]]) {
                self.serviceProvider.serviceUserID = [jsonDict objectForKey:kBTC2ServiceProviderUserIDKey];
                if ([self.delegate respondsToSelector:@selector(btc2DidUpdateServiceProvider:forSession:)]) {
                    [NSObject btc2ExecuteOnMainThread:^{
                        [self.delegate btc2DidUpdateServiceProvider:BTC2ServiceProviderPropertyServiceUserID forSession:self];
                    }];
                }
            }
        }else{
            DLog(@"No dictionary? %@ of class %@", jsonDict, [jsonDict class]);
        }
    }else{
        DLog(@"Error: %@", error);
    }
}

@end
