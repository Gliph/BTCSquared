//
//  BTC2ServiceProviderModel.h
//  BTC2
//
//  Created by Joakim Fernstad on 6/12/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum BTC2ServiceProviderPropertyEnum {
    BTC2ServiceProviderPropertyServiceName = 0,
    BTC2ServiceProviderPropertyServiceUserID,
}BTC2ServiceProviderPropertyEnum;

@interface BTC2ServiceProviderModel : NSObject
@property (nonatomic, strong) NSString* serviceName;
@property (nonatomic, strong) NSString* serviceUserID;
-(NSData*)serviceNameJSON;
-(NSData*)serviceUserIDJSON;
@end
