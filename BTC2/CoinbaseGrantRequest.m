//
//  CoinbaseGrantRequest.m
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "CoinbaseGrantRequest.h"
//#import <SBJson/SBJson.h>

@implementation CoinbaseGrantRequest

+(NSURL*)getRedirectURIForScope:(NSString*)scope withRedirectURIPrefix:(NSString*)redirectURIPrefix withClientId:(NSString*)clientId {
    NSString* queryString = [NSString stringWithFormat:@"response_type=code&client_id=%@&scope=%@&redirect_uri=%@", clientId, scope, redirectURIPrefix];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://coinbase.com/oauth/authorize?%@", queryString]];
}

+(void)fetchTokensWithCodeFromCallbackAndRedirectURI:(NSString*)codeFromCallback withRedirectURI:(NSURL*)redirectURI withClientId:(NSString*)clientId withClientSecret:(NSString*)clientSecret withFinishBlock:(RequestFinished)successBlock {
    CoinbaseGrantRequest* grantRequest = [[CoinbaseGrantRequest alloc] init];
    
    grantRequest.postDict = @{@"grant_type": @"refresh_token",
                              @"client_id": clientId,
                              @"client_secret": clientSecret,
                              @"redirect_uri": redirectURI,
                              @"code": codeFromCallback};
    
    grantRequest.finishBlock = successBlock;
    grantRequest.failBlock = nil;
    
    [grantRequest execute];
}

+(void)fetchTokensWithRefreshToken:(NSString*)refreshToken withClientId:(NSString*)clientId withClientSecret:(NSString*)clientSecret withFinishBlock:(RequestFinished)successBlock {
    CoinbaseGrantRequest* grantRequest = [[CoinbaseGrantRequest alloc] init];
    
    grantRequest.postDict = @{@"grant_type": @"refresh_token",
                              @"client_id": clientId,
                              @"client_secret": clientSecret,
                              @"refresh_token": refreshToken};
    
    grantRequest.finishBlock = successBlock;
    grantRequest.failBlock = nil;
    
    [grantRequest execute];
}


- (void)setupOperation{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://coinbase.com/oauth/token"]];
    NSData* postData = nil;//[self httpDataWithDictionary:self.postDict];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    self.request = request;
    NSLog(@"Shooting off URL: https://coinbase.com/oauth/token");
}


- (id)createModelObjectWithDict:(NSDictionary *)dic{
    // Pass through by default
    return dic;
}

-(id)objectFromResponse{
    NSString* jsonData = nil;
    NSDictionary* dic = nil;
    id parsedObject = nil;
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    jsonData = [[[NSString alloc] initWithData:self.storedData encoding:NSUTF8StringEncoding] autorelease];
    
    parsedObject = [parser objectWithString:jsonData];
    
    if (parsedObject) {
        if ([parsedObject isKindOfClass:[NSDictionary class]]) {
            dic = parsedObject;
        }
        else if ([parsedObject isKindOfClass:[NSArray class]]) {
            dic = [NSDictionary dictionaryWithObject:parsedObject forKey:@"Array"];
        }
        else
        {
            DLog(@"Parser returned unexpected object");
        }
    }
    return dic;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"CoinbaseGrantRequest - Base [0x%x]", self.hash];
}
@end
