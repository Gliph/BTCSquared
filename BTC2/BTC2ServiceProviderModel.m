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
//  BTC2ServiceProviderModel.m
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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
