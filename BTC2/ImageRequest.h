//
//  ImageRequest.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BaseRequest.h"

@interface ImageRequest : BaseRequest
@property (nonatomic, strong) NSURL* requestURL;
@property (nonatomic, assign, getter = isRetina) BOOL retina;
-(id)initWithURL:(NSURL*)url;

// Any image
+(void)fetchImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock;
+(void)fetchImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock;

// Treat as retina image
+(void)fetchRetinaImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock;
+(void)fetchRetinaImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock;
@end
