//
//  BTC2IdentificationModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2IdentificationModel.h"
#import "BTC2Constants.h"
#import "NSDictionary+BTC2Extensions.h"

@implementation BTC2IdentificationModel

-(NSData*)pseudonymJSON{
    NSData* encodedData = nil;
    
    if (self.pseudonym.length) {
        encodedData = [@{kBTC2IdentificationPseudonymKey: self.pseudonym} btc2RenderedJSON]; // Fun with modern objective-c. :)
    }
    
    return encodedData;
}

-(NSData*)avatarURLJSON{
    NSData* encodedData = nil;
    
    if (self.avatarURL.absoluteString.length) {
        encodedData = [@{kBTC2IdentificationAvatarURLKey: self.avatarURL.absoluteString} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSData*)avatarServiceNameJSON{
    NSData* encodedData = nil;
    
    // Both must be fulfilled.
    if (self.avatarServiceName.length && self.avatarID.length) {
        encodedData = [@{kBTC2IdentificationAvatarServiceKey: self.avatarServiceName} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSData*)avatarIDJSON{
    NSData* encodedData = nil;
    
    // Both must be fulfilled.
    if (self.avatarServiceName.length && self.avatarID.length) {
        encodedData = [@{kBTC2IdentificationAvatarIDKey: self.avatarID} btc2RenderedJSON];
    }
    
    return encodedData;
}


@end
