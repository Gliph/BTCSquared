//
//  BTC2IdentificationModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTC2IdentificationModel : NSObject
@property (nonatomic, strong) NSString* pseudonym;
@property (nonatomic, strong) NSURL* avatarURL;
@property (nonatomic, strong) NSString* avatarServiceName;
@property (nonatomic, strong) NSString* avatarID;
-(NSData*)data; // Compact JSON formatted avatarService + avatarID
@end
