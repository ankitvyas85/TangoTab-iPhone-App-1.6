//
//  SearchDetailViewController.h
//  TangoTab
//
//  Created by Sirisha G on 20/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"
#import "SearchMapViewcontroller.h"
#import "ASINetworkQueue.h"
#import "ActivityIndicatorView.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "FlurryAnalytics.h"
#import "EasyTracker.h"
#import "GANTracker.h"
#import "AsyncImageView.h"
//#import "FaceBook.h"
//#import "Twitter.h"
//#import "PostTwitterViewController.h"
//#import "PostFacebookViewController.h"

@class AppDelegate;
@class FlurryAnalytics;
@class Mapviewcontroller;
@class SearchMapViewcontroller;
@class AsyncImageView;
//@class FaceBook;
//@class Twitter;

@interface SearchDetailViewController : TrackedUIViewController<NSXMLParserDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) IBOutlet AsyncImageView *myImageView;
@property (nonatomic, retain) SearchMapViewcontroller *searchmapViewCtrl;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *restaurantLocationLabel;
@property (nonatomic, retain) IBOutlet UILabel *dealNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *creditValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *cuisineTypeIdLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateAndTimeLabel;
@property (nonatomic, retain) IBOutlet UIButton *dealTimeButton;
@property (nonatomic, retain) IBOutlet UILabel *dealDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *dealRestriction;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, retain) NSMutableString *currentelement,*dealStatus;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;


//-(void)postfacebookviewcontroller;
//-(void)tweetwitterviewcontrolle;
-(IBAction)fixDealButtonClicked:(id)sender;
-(IBAction)mapButtonClicked:(id)sender;
- (void) parseXML:(NSString *) xmlString;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;
- (void) showActivityIndicatorView;
- (void) stopActivityIndicatorView;

@end
