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
//  ImageRequest.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
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

+(void)fetchRetinaImageWithURL:(NSURL*)url andFinishBlock:(RequestFinished)successBlock{
    [ImageRequest imageWithURL:url withRetina:YES withSuccess:successBlock andFail:nil];
};
+(void)fetchRetinaImageWithURL:(NSURL*)url finishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock{
    [ImageRequest imageWithURL:url withRetina:YES withSuccess:successBlock andFail:failBlock];
};
+(void)fetchImageWithURL:(NSURL*)url andFinishBlock:(RequestFinished)successBlock{
    [ImageRequest imageWithURL:url withRetina:NO withSuccess:successBlock andFail:nil];
}
+(void)fetchImageWithURL:(NSURL*)url finishBlock:(RequestFinished)successBlock andFailBlock:(RequestFailed)failBlock{
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
