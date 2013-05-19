//
//  CoinbaseBaseRequest.h
//  BTC2
//
//  Created by Nicholas Asch on 2013-05-19.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRequest.h"

@interface CoinbaseBaseRequest : BaseRequest
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* apiEndpoint;
@end