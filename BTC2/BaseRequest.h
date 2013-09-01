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
//  BaseRequest.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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
