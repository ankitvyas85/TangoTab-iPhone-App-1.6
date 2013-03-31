//
//  SilverPop.h
//  TangoTab
//
//  Created by Mark Crutcher on 11/3/12.
//
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
@class ASIHTTPRequest;

@interface SilverPop : NSObject

@property BOOL result;

@property (nonatomic, retain) ASINetworkQueue *networkQueue;

- (BOOL) invokeWithDealId: (NSString *) dealId;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;
- (void)FetchComplete:(ASIHTTPRequest *)request;
- (void)FetchFailed:(ASIHTTPRequest *)request;

@end
