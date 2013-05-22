//
//  ImageRequest.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "ImageRequest.h"

@interface ImageRequest()
+(void)imageWithURL:(NSURL*)url withRetina:(BOOL)useRetina withSuccess:(RequestFinished)sb andFail:(RequestFailed)fb;
@end

@implementation ImageRequest
@synthesize requestURL;
@synthesize retina = m_retina;

// Convenience
+(void)imageWithURL:(NSURL*)url withRetina:(BOOL)useRetina withSuccess:(RequestFinished)sb andFail:(RequestFailed)fb{
    ImageRequest* imageFetcher = [[ImageRequest alloc] initWithURL:url];
    
    imageFetcher.finishBlock = sb;
    imageFetcher.failBlock = fb;
    imageFetcher.retina = useRetina;
    
    [imageFetcher execute];
}

+(void)fetchRetinaImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock{
    [ImageRequest imageWithURL:url withRetina:YES withSuccess:successBlock andFail:nil];
};
+(void)fetchRetinaImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock{
    [ImageRequest imageWithURL:url withRetina:YES withSuccess:successBlock andFail:failBlock];
};
+(void)fetchImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock{
    [ImageRequest imageWithURL:url withRetina:NO withSuccess:successBlock andFail:nil];
}
+(void)fetchImageWithURL:(NSURL*)url withFinishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock{
    [ImageRequest imageWithURL:url withRetina:NO withSuccess:successBlock andFail:failBlock];
}

-(id)initWithURL:(NSURL*)url{
    if ((self = [super init])) {
        self.requestURL = url;
    }
    return self;
}


#pragma mark - Subclass overrides

- (void)setupOperation{
    
    NSMutableURLRequest* request = nil;
    
    request = [NSMutableURLRequest requestWithURL:self.requestURL];
    
    [request setHTTPMethod:@"GET"];
    
    self.request = request;
    DLog(@"Shooting off URL: %@", self.requestURL);
}

-(id)objectFromResponse{
    UIImage* image = [UIImage imageWithData:self.storedData];
    CGFloat imageScale = 1.0;
    
    // The image we download is retina size
    if (self.isRetina) {
        imageScale = 2.0;
    }

    image = [UIImage imageWithCGImage:image.CGImage
                                scale:imageScale
                          orientation:UIImageOrientationUp];

    return image;
}

#pragma mark - NSObject override

-(NSString*)description{
    return [NSString stringWithFormat:@"ImageRequest - Base [0x%x]", self.hash];
}

@end
