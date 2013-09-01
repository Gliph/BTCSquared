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
//  BTC2UUIDs.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#ifndef BTC2_BTC2UUIDS_h
#define BTC2_BTC2UUIDS_h

// Base UUID
extern NSString* const kBTC2BaseUUID;

//
// Wallet service
//
extern NSString* const kBTC2WalletServiceUUID;
// Central initiates
extern NSString* const kBTC2WalletAddressReadUUID;
extern NSString* const kBTC2WalletPaymentWriteUUID;
extern NSString* const kBTC2WalletNoticeWriteUUID;
// Peripheral initiates
extern NSString* const kBTC2WalletAddressWriteUUID;
extern NSString* const kBTC2WalletPaymentNotificationUUID;
extern NSString* const kBTC2WalletNoticeNotificationUUID;

//
// Identification service
//
extern NSString* const kBTC2IDServiceUUID;
// Central initiates
extern NSString* const kBTC2IDPseudonymReadUUID;
extern NSString* const kBTC2IDAvatarServiceReadUUID;
extern NSString* const kBTC2IDAvatarIDReadUUID;
extern NSString* const kBTC2IDAvatarURLReadUUID;
//extern NSString* const BTC2IDImageReadUUID;
// Peripheral initiates
extern NSString* const kBTC2IDPseudonymWriteUUID;
extern NSString* const kBTC2IDAvatarServiceWriteUUID;
extern NSString* const kBTC2IDAvatarIDWriteUUID;
extern NSString* const kBTC2IDAvatarURLWriteUUID;
//extern NSString* const BTC2IDImageWriteUUID;

//
// Service provider service
//
extern NSString* const kBTC2ServiceProviderServiceUUID;
// Central initiated
extern NSString* const kBTC2ServiceProviderNameReadUUID;
extern NSString* const kBTC2ServiceProviderUserIDReadUUID;
// Peripheral initiates
extern NSString* const kBTC2ServiceProviderNameWriteUUID;
extern NSString* const kBTC2ServiceProviderUserIDWriteUUID;


#endif // BTC2_BTC2UUIDS_h
