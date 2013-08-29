//
//  BTC2IdentityModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum BTC2IdentityPropertyEnum {
    BTC2IdentityPropertyPseudonym = 0,
    BTC2IdentityPropertyAvatarURL,
    BTC2IdentityPropertyAvatarServiceName,
    BTC2IdentityPropertyAvatarID
}BTC2IdentityPropertyEnum;

@interface BTC2IdentityModel : NSObject
@property (nonatomic, strong) NSString* pseudonym;
@property (nonatomic, strong) NSURL* avatarURL;
@property (nonatomic, strong) NSString* avatarServiceName;
@property (nonatomic, strong) NSString* avatarID;

-(NSData*)pseudonymJSON;
-(NSData*)avatarURLJSON;
-(NSData*)avatarServiceNameJSON;
-(NSData*)avatarIDJSON;
@end
