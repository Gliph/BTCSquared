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
//  BTC2AvatarServices.m
//  BTC2
//
//  Created by Joakim Fernstad on 9/2/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2AvatarServices.h"

#define kBTC2AvatarServiceRobohash      @"robohash"
#define kBTC2AvatarServiceGravatar      @"gravatar"

@interface BTC2AvatarServices ()
+(NSURL*)gravatarURLForAvatarID:(NSString*)avatarID andSize:(CGSize)imageSize;
+(NSURL*)robohashURLForAvatarID:(NSString*)avatarID andSize:(CGSize)imageSize;
@end

@implementation BTC2AvatarServices

+(NSArray*)supportedAvatarServices{
    return @[kBTC2AvatarServiceRobohash,
             kBTC2AvatarServiceGravatar];
}

+(NSURL*)avatarImageURLForService:(NSString*)avatarService withID:(NSString*)avatarID{
    return [BTC2AvatarServices avatarImageURLForService:avatarService withID:avatarID andSize:CGSizeMake(200,200)];
}

+(NSURL*)avatarImageURLForService:(NSString*)avatarService withID:(NSString*)avatarID andSize:(CGSize)imageSize{
    NSURL* avatarURL = nil;
    
    if (avatarService.length &&
        [avatarService caseInsensitiveCompare:kBTC2AvatarServiceRobohash] == NSOrderedSame) {
        avatarURL = [BTC2AvatarServices robohashURLForAvatarID:avatarID andSize:imageSize];
    }
    else if (avatarService.length &&
        [avatarService caseInsensitiveCompare:kBTC2AvatarServiceGravatar] == NSOrderedSame) {
        avatarURL = [BTC2AvatarServices robohashURLForAvatarID:avatarID andSize:imageSize];
    }
    return avatarURL;
}

#pragma mark - Specific services URL assemblers

+(NSURL*)gravatarURLForAvatarID:(NSString*)avatarID andSize:(CGSize)imageSize{
    NSURL* gravatarURL = nil;
    NSString* urlString = @"http://www.gravatar.com/avatar/%@";
    
    if (avatarID.length){
        urlString = [NSString stringWithFormat:urlString, avatarID];
        
        if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {

            // In case the avatarID contain URL arguments
            NSRange r = [urlString rangeOfString:@"?"];
            
            if (r.location == NSNotFound) {
                urlString = [urlString stringByAppendingString:@"?"];
            }
            
            urlString = [urlString stringByAppendingFormat:@"&s=%d", (int)imageSize.width];
        }
        
        gravatarURL = [NSURL URLWithString:urlString];
    }
    
    return gravatarURL;
}
+(NSURL*)robohashURLForAvatarID:(NSString*)avatarID andSize:(CGSize)imageSize{
    NSURL* robohashURL = nil;
    NSString* urlString = @"http://robohash.org/%@";
    
    if (avatarID.length){
        urlString = [NSString stringWithFormat:urlString, avatarID];
        
        if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {
            
            // In case the avatarID contain URL arguments
            NSRange r = [urlString rangeOfString:@"?"];
            
            if (r.location == NSNotFound) {
                urlString = [urlString stringByAppendingString:@"?"];
            }
            
            urlString = [urlString stringByAppendingFormat:@"&size=%dx%d", (int)imageSize.width, (int)imageSize.height];
        }
        
        robohashURL = [NSURL URLWithString:urlString];
    }
    
    return robohashURL;
}

@end
