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
//  BTC2IdentityModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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
