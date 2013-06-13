//
//  BTC2UUIDs.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#ifndef BTC2_BTC2UUIDs_h
#define BTC2_BTC2UUIDs_h

// Base UUID
#define BTC2BaseUUID                         @"00000000-AAA7-4E52-BB94-03EF9B262830"

//
// Wallet service
//
#define BTC2WalletServiceUUID                @"0000D900-AAA7-4E52-BB94-03EF9B262830"
// Central initiates
#define BTC2WalletAddressReadUUID            @"0000D9A1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2WalletPaymentWriteUUID           @"0000D9A2-AAA7-4E52-BB94-03EF9B262830"
#define BTC2WalletNoticeWriteUUID            @"0000D9A3-AAA7-4E52-BB94-03EF9B262830"
// Peripheral initiates
#define BTC2WalletAddressWriteUUID           @"0000D9B1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2WalletPaymentIndicateUUID        @"0000D9B2-AAA7-4E52-BB94-03EF9B262830"
#define BTC2WalletNoticeIndicateUUID         @"0000D9B3-AAA7-4E52-BB94-03EF9B262830"

//
// Identification service
//
#define BTC2IDServiceUUID                    @"00008300-AAA7-4E52-BB94-03EF9B262830"
// Central initiates
#define BTC2IDPseudonymReadUUID              @"000083C1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2IDAvatarReadUUID                 @"000083C2-AAA7-4E52-BB94-03EF9B262830"
#define BTC2IDAvatarURLReadUUID              @"000083C3-AAA7-4E52-BB94-03EF9B262830"
//#define BTC2IDImageReadUUID                  @"000083C4-AAA7-4E52-BB94-03EF9B262830" // Wait with this one
// Peripheral initiates
#define BTC2IDPseudonymWriteUUID             @"000083D1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2IDAvatarWriteUUID                @"000083D2-AAA7-4E52-BB94-03EF9B262830"
#define BTC2IDAvatarURLWriteUUID             @"000083D3-AAA7-4E52-BB94-03EF9B262830"
//#define BTC2IDImageWriteUUID                 @"000083D4-AAA7-4E52-BB94-03EF9B262830" // Wait with this one, tricky to write large chunks from central to peripheral

//
// Service provider service
//
#define BTC2ServiceProviderServiceUUID       @"00004500-AAA7-4E52-BB94-03EF9B262830"
// Central initiated
#define BTC2ServiceProviderNameReadUUID      @"000045E1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2ServiceProviderUserIDReadUUID    @"000045E2-AAA7-4E52-BB94-03EF9B262830"
// Peripheral initiates
#define BTC2ServiceProviderNameWriteUUID     @"000045F1-AAA7-4E52-BB94-03EF9B262830"
#define BTC2ServiceProviderUserIDWriteUUID   @"000045F2-AAA7-4E52-BB94-03EF9B262830"


#endif
