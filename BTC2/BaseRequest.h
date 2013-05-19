//
//  BaseRequest.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_RETRIES                  5
#define REQUEST_TIMEOUT             15 // seconds, Apple has a minumum of 240 seconds for POSTs
#define MAX_CONCURRENT_OPERATIONS    1

@class BaseRequest;

typedef enum : NSUInteger {
    BaseRequestSucceded    = 0,
    BaseRequestFail,            // General fail, should be same as "unknown"?
    BaseRequestTimeout
}BaseResponseCodeEnum;

typedef NSUInteger BaseResponseCode;

typedef void (^RequestFinished)(id response);
typedef void (^RequestFailed)(NSUInteger responseCode);
typedef void (^RequestProgress)(CGFloat progress);

@interface BaseRequest : NSOperation <NSURLConnectionDataDelegate>

@property (nonatomic, copy)   RequestFinished finishBlock;
@property (nonatomic, copy)   RequestFailed failBlock;
@property (nonatomic, copy)   RequestProgress uploadProgressBlock;
@property (nonatomic, strong) NSMutableURLRequest* request;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* storedData;
@property (nonatomic, assign) NSUInteger retries;
@property (nonatomic, assign) BOOL shouldContinueInBackground;
@property (readonly) CGFloat uploadProgress;

+(NSOperationQueue*)sharedQueue;

-(id)objectFromResponse; // Override to convert response to a defined object

// Call execute to start the request
-(void)execute;

-(void)startOperation;  // Should not be called by subclass unless overriding execute
-(void)setupOperation;  // Subclass should override to setup the request
-(void)cancel;          // Abort
-(void)finish;          // Should not be called by user, only from subclass if it overrides the connection delegate

@end
