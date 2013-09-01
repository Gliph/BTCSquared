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
//  BTC2IdentityModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2IdentityModel.h"
#import "BTC2Constants.h"
#import "NSDictionary+BTC2Extensions.h"

@implementation BTC2IdentityModel

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

-(NSString*)description{
    return [NSString stringWithFormat:@"%@. AvatarURL: %@. AvatarService: %@. AvatarID: %@", self.pseudonym, self.avatarURL, self.avatarServiceName, self.avatarID];
}

@end
