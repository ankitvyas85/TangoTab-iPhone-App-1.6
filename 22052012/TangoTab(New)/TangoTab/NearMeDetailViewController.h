//
//  NearMeDetailViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HeaderFiles.h"
#import "AsyncImageView.h"
#import "defines.h"
#import "ActivityIndicatorView.h"
#import "AppDelegate.h"
#import "Mapviewcontroller.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


@class AppDelegate;
@class Mapviewcontroller;

@interface NearMeDetailViewController : TrackedUIViewController <NSXMLParserDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) IBOutlet AsyncImageView *myImageView;
@property (nonatomic, retain) Mapviewcontroller *mapViewCtrl;


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
@property(nonatomic,assign)BOOL failed;
@property(nonatomic,retain)NSMutableString *currentelement,*dealStatus;
@property(nonatomic,retain)ActivityIndicatorView *activityIndicatorView;



-(IBAction)fixDealButtonClicked:(id)sender;
-(IBAction)mapButtonClicked:(id)sender;
-(IBAction)back:(id)sender;
- (void) parseXML:(NSString *) xmlString;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;
- (void) showActivityIndicatorView;
- (void) stopActivityIndicatorView;

@end
