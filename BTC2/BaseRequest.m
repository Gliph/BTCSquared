//
//  BaseRequest.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BaseRequest.h"
#import "NetworkController.h"

@interface BaseRequest()
@property (atomic, assign) BOOL isExecuting;
@property (atomic, assign) BOOL isFinished;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, readonly) BOOL hasBlocks;
@property (readwrite) CGFloat uploadProgress;
@end

@implementation BaseRequest
@synthesize finishBlock = _finishBlock;
@synthesize failBlock = _failBlock;
@synthesize uploadProgressBlock = _uploadProgressBlock;
@synthesize connection;
@synthesize request;
@synthesize storedData;
@synthesize retries;
@synthesize shouldContinueInBackground = _shouldContinueInBackground;
@synthesize backgroundTask = _backgroundTask;
@synthesize uploadProgress = _uploadProgress;

// NSOperation
@synthesize isExecuting = m_isExecuting;
@synthesize isFinished = m_isFinished;

+(NSOperationQueue*)sharedQueue{
    static dispatch_once_t pred = 0;
    static NSOperationQueue* queue = nil;
    dispatch_once(&pred, ^{
        queue = [[NSOperationQueue alloc] init]; // or some other init method
        [queue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATIONS];
    });
    return queue;
}

-(id)init{
    if ((self = [super init])) {
        self.retries = 0;
        self.isExecuting = NO;
        self.isFinished = NO;
    }
    return self;
}


- (void)dealloc{
    
    self.retries = 0;
    
    // Just in case finish was never called
    if (_backgroundTask && _backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
    
}

- (BOOL)hasBlocks {
    return (self.finishBlock || self.failBlock || self.uploadProgressBlock);
}

#pragma mark - Multitasking

- (BOOL)isMultitaskingSupported {
    BOOL multiTaskingSupported = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        multiTaskingSupported = [(id)[UIDevice currentDevice] isMultitaskingSupported];
    }
    return multiTaskingSupported;
}

- (void)beginBackgroundTask {
    if ([self isMultitaskingSupported] && self.shouldContinueInBackground) {
        if (!_backgroundTask || _backgroundTask == UIBackgroundTaskInvalid) {
            _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self cancel];
                [self endBackgroundTask];
            }];
        }
    }
}

- (void)endBackgroundTask {
    if ([self isMultitaskingSupported]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_backgroundTask && _backgroundTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
                _backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }
}

#pragma mark - NSOperation overrides

- (void)start{
    // Do the actual execution
    
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSPort* port = [NSPort port];
    NSRunLoop* thisRunloop = [NSRunLoop currentRunLoop]; // Get the runloop
    [thisRunloop addPort:port forMode:NSDefaultRunLoopMode];
    [self.connection scheduleInRunLoop:thisRunloop forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
    if (self.isCancelled) {
        DLog(@" - Abort before start [0x%x]", [self hash]);
        [self.connection cancel];
        [self finish];
        return;
    }
    
    do {
        [thisRunloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }while(!self.isFinished && !self.isCancelled);
    
    if (self.isCancelled) {
        DLog(@" - Abort during execution");
        [self.connection cancel];
        [self finish];
    }
}
- (BOOL)isConcurrent{
    return YES;
}
-(void)finish{
    DLog(@"%@ finished", [self description]);
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.isExecuting = NO;
    self.isFinished = YES;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
    if (self.isCancelled) {
        DLog(@"GOT CANCELLED! %@", self);
    }
    
    [self endBackgroundTask];
}

- (void)startOperation{
    if (!self.isCancelled) {
        if (self.request) {
            
            DLog(@"Executing %@", [self description]);
            [NetworkController increaseActivity];
            [self beginBackgroundTask];
            
            [self.request setTimeoutInterval:REQUEST_TIMEOUT];
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                               delegate:self
                                                       startImmediately:NO];
            
            [[BaseRequest sharedQueue] addOperation:self];
        }
        else {
            NSAssert(FALSE,@"Request is NULL! Fix the code!");
        }
    }
}

-(id)objectFromResponse{
    // Default implementation, subclass should implement their own object
    // This object will be passed into the finishBlock
    return self.storedData;
}
- (void)setupOperation{
    // Subclass should use this to create the NSURLRequest
}

- (void)execute{
    if (self.isCancelled) {
        return;
    }
    
    [self setupOperation];
    [self startOperation];
}
#pragma mark - Base methods

-(void)cancel{
    DLog(@"Cancelled called [0x%x]", [self hash]);
    [super cancel]; // NSOperation cancel
    [NetworkController decreaseActivity];
}


#pragma mark - URL Connection Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response{
    DLog(@"didReceiveResponse: %@, Code: %d", response.URL, response.statusCode);
    // TODO: Handle failed connection responses here.
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (!self.storedData) {
        self.storedData = [[NSMutableData alloc] init];
    }
    
    [self.storedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    DLog(@"Connection failed with error: %@", error);
    
    if (self.hasBlocks) {
        BaseResponseCode code = BaseRequestFail;
        if ([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -1001) {
            code = BaseRequestTimeout;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.failBlock)
                self.failBlock(code);
            self.failBlock = nil;
            self.finishBlock = nil;
            self.uploadProgressBlock = nil;
        });
    }
    
    [self finish];
    [NetworkController decreaseActivity];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    self.uploadProgress = progress;
    if (self.uploadProgressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadProgressBlock(progress);
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    DLog(@"");
    
    if (self.hasBlocks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.finishBlock)
                self.finishBlock([self objectFromResponse]);
            self.failBlock = nil;
            self.finishBlock = nil;
            self.uploadProgressBlock = nil;
        });
    }
    [self finish];
    [NetworkController decreaseActivity];
}

- (NSCachedURLResponse*)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil; // Disable storing every request in cache on disk
}
#pragma mark - NSObject override

-(NSString*)description{
    return [NSString stringWithFormat:@"BaseRequest - Base [0x%x]", self.hash];
}

@end
