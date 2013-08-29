//
//  BTC2UUIDs.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
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
extern NSString* const kBTC2WalletPaymentIndicateUUID;
extern NSString* const kBTC2WalletNoticeIndicateUUID;

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
