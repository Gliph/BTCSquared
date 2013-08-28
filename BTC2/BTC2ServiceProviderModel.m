//
//  BTC2ServiceProviderModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2ServiceProviderModel.h"
#import "BTC2Constants.h"
#import "NSDictionary+BTC2Extensions.h"

@implementation BTC2ServiceProviderModel

-(NSData*)serviceNameJSON{
    NSData* encodedData = nil;
    
    if (self.serviceName.length) {
        encodedData = [@{kBTC2ServiceProviderNameKey: self.serviceName} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSData*)serviceUserIDJSON{
    NSData* encodedData = nil;
    
    if (self.serviceUserID.length) {
        encodedData = [@{kBTC2ServiceProviderUserIDKey: self.serviceUserID} btc2RenderedJSON];
    }
    
    return encodedData;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"Service: %@. UserID: %@", self.serviceName, self.serviceUserID];
}

@end
