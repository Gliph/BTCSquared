//
//  CoinbaseRequest.h
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinbaseRequest : BaseRequest
+(NSURL)initWithoutAuthorization;
+(void)initWithAuthorization:(NSString)accessToken (NSString);
+(void)fetchRetinaImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock;
@end
