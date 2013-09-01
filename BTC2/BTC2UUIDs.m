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
//  BTC2UUIDs.m
//  BTC2
//
//  Created by Joakim Fernstad on 8/24/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2UUIDs.h"
// Base UUID
NSString* const kBTC2BaseUUID                       = @"00000000-AAA7-4E52-BB94-03EF9B262830";

//
// Wallet service
//
NSString* const kBTC2WalletServiceUUID              = @"0000D900-AAA7-4E52-BB94-03EF9B262830";
// Central initiates
NSString* const kBTC2WalletAddressReadUUID          = @"0000D9A1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2WalletPaymentWriteUUID         = @"0000D9A2-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2WalletNoticeWriteUUID          = @"0000D9A3-AAA7-4E52-BB94-03EF9B262830";
// Peripheral initiates
NSString* const kBTC2WalletAddressWriteUUID         = @"0000D9B1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2WalletPaymentNotificationUUID  = @"0000D9B2-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2WalletNoticeNotificationUUID   = @"0000D9B3-AAA7-4E52-BB94-03EF9B262830";

//
// Identification service
//
NSString* const kBTC2IDServiceUUID                  = @"00008300-AAA7-4E52-BB94-03EF9B262830";
// Central initiates
NSString* const kBTC2IDPseudonymReadUUID            = @"000083C1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarServiceReadUUID        = @"000083C2-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarIDReadUUID             = @"000083C3-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarURLReadUUID            = @"000083C4-AAA7-4E52-BB94-03EF9B262830";
//const NSString*  BTC2IDImageReadUUID                 = @"000083C5-AAA7-4E52-BB94-03EF9B262830" // Wait with this one
// Peripheral initiates
NSString* const kBTC2IDPseudonymWriteUUID           = @"000083D1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarServiceWriteUUID       = @"000083D2-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarIDWriteUUID            = @"000083D3-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2IDAvatarURLWriteUUID           = @"000083D4-AAA7-4E52-BB94-03EF9B262830";
//const NSString* kBTC2IDImageWriteUUID                = @"000083D5-AAA7-4E52-BB94-03EF9B262830" // Wait with this one, tricky to write large chunks from central to peripheral

//
// Service provider service
//
NSString* const kBTC2ServiceProviderServiceUUID     = @"00004500-AAA7-4E52-BB94-03EF9B262830";
// Central initiated
NSString* const kBTC2ServiceProviderNameReadUUID    = @"000045E1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2ServiceProviderUserIDReadUUID  = @"000045E2-AAA7-4E52-BB94-03EF9B262830";
// Peripheral initiates
NSString* const kBTC2ServiceProviderNameWriteUUID   = @"000045F1-AAA7-4E52-BB94-03EF9B262830";
NSString* const kBTC2ServiceProviderUserIDWriteUUID = @"000045F2-AAA7-4E52-BB94-03EF9B262830";

