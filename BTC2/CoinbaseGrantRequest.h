//
//  CoinbaseGrantRequest.h
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRequest.h"

@interface CoinbaseGrantRequest : BaseRequest
@property (nonatomic, strong) NSDictionary* postDict;

+(NSURL*)getAuthorizationURLForScope:(NSString*)scope withRedirectURIPrefix:(NSString*)redirectURIPrefix withClientId:(NSString*)clientId;

+(void)fetchTokensWithCodeFromCallbackAndRedirectURI:(NSString*)codeFromCallback withRedirectURI:(NSURL*)redirectURI withClientId:(NSString*)clientId withClientSecret:(NSString*)clientSecret withFinishBlock:(RequestFinished)successBlock;
+(void)fetchTokensWithRefreshToken:(NSString*)refreshToken withClientId:(NSString*)clientId withClientSecret:(NSString*)clientSecret withFinishBlock:(RequestFinished)successBlock;

@end
