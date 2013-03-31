//
//  SilverPop.m
//  TangoTab
//
//  Created by Mark Crutcher on 11/3/12.
//
//

#import "SilverPop.h"
#import "AppDelegate.h"

@implementation SilverPop
@synthesize networkQueue;

- (BOOL) invokeWithDealId: (NSString *) dealId 
{
    NSString *mailingId = nil, *userId = nil, *jobId = nil;
    self.result = NO;    
    
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (sharedDelegate.urlActionParameters != nil)
    {
        mailingId = [sharedDelegate.urlActionParameters valueForKey:@"spMailingId"];
        userId = [sharedDelegate.urlActionParameters valueForKey:@"spUserId"];
        jobId = [sharedDelegate.urlActionParameters valueForKey:@"spJobId"];
    }
    if (mailingId != nil && userId != nil && jobId != nil)
    {
        @try {
            NSString *serviceURL = [NSString stringWithFormat:@"http://recp.mkt51.net/cot?m=%@&r=%@&j=%@&a=iOS&d=%@&amt=4",mailingId,userId,jobId, dealId];
            NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            debug_NSLog(@"Silverpop-> %@",[url absoluteString]);
            [self sendASIHTTPRequest:url];
            [sharedDelegate.urlActionParameters setObject:nil forKey:@"spMailingId"];
            [sharedDelegate.urlActionParameters setObject:nil forKey:@"spUserId"];
            [sharedDelegate.urlActionParameters setObject:nil forKey:@"spJobId"];
        }
        @catch (NSException *exception) {
            self.result = NO;
        }
    }
    else{
        debug_NSLog(@"Silverpop parameters not set");
    }
    
    return self.result;
}

-( void) sendASIHTTPRequest:(NSURL*)serverURLs
{
    
    if (networkQueue) {
        [networkQueue cancelAllOperations];
        [networkQueue setDelegate:nil];
    }
    [networkQueue reset];
    networkQueue = [[ASINetworkQueue alloc] init];
    [networkQueue setRequestDidFinishSelector:@selector(FetchComplete:)];
    [networkQueue setRequestDidFailSelector:@selector(FetchFailed:)];
    [networkQueue setDelegate:self];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:serverURLs];
    [request setTimeOutSeconds:60];
    [networkQueue addOperation:request];
    [networkQueue go];
    
}

- (void)FetchComplete:(ASIHTTPRequest *)request
{
    NSString *respose = [request responseString];
    debug_NSLog(@"Silverpop Success <- %@",respose);
    
    self.result = YES;
}

- (void)FetchFailed:(ASIHTTPRequest *)request
{
    debug_NSLog(@"Silverpop Failed");
    self.result = NO;
}

@end
