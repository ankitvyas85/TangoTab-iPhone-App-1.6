//
//  NearMeViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "defines.h"
#import "ActivityIndicatorView.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "NearMeDetailViewController.h"
#import "AppDelegate.h"
#import "MyCLLocation.h"
#import "NearMeCustomCell.h"
#import "Mapviewcontroller.h"
#import "AsyncImageView.h"
#import "EasyTracker.h"
#import "GANTracker.h"

@class ActivityIndicatorView;
@class AppDelegate;
@class ASINetworkQueue;
@class NearMeDetailViewController;


extern NSString * const NotifyUrlAction;

@interface NearMeViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,MyCLLocationDelegate,MKReverseGeocoderDelegate>

@property (nonatomic, retain) IBOutlet UITableView *nearTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapBarButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) NSString *serverURL;
@property (nonatomic, retain) NSArray *addressArray;
@property (nonatomic, retain) NSMutableArray *allEntries,*imagesArray;
@property (nonatomic, retain) NSMutableDictionary *details;
@property (nonatomic, retain) NSString *currentElement,*dealid;
@property (nonatomic, retain) NSMutableString *noOfdeals,*dealsfrom,*cuisine_type_id,*driving_distance,*business_name,*deal_name,*image_url,*rest_deal_restrictions,*deal_description,*rest_deal_availablestart_date,*rest_deal_start_date,*rest_deal_end_date,*available_start_time,*available_end_time,*available_week_days,*deal_credit_value,*location_rest_address,*address,*no_deals_available;
@property (nonatomic, retain) UILabel *nodata_Lable;
@property (nonatomic, retain) UIButton *showMore;

@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property (nonatomic, retain) CLGeocoder *myGeocoder;

@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) MyCLLocation *myLocation;
@property (nonatomic, retain) NearMeDetailViewController *nearmeDetailVCtrl;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) Mapviewcontroller *mapViewCtrl;

@property int pageIndex;
@property int noOfOffers;
@property BOOL failed;

//- (void)reloadTableViewDataSource;
//- (void)doneLoadingTableViewData;


-(IBAction)mapButtonClicked:(id)sender;

- (void) parseXML:(NSString *) xmlString;
- (void) refresh : (NSDictionary *)addressDict;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;

- (void) showActivityIndicatorView;
- (void) stopActivityIndicatorView;

- (void) locationUpdate:(CLLocation *)location;
- (void) locationError :(NSError *)error;
- (void) reverseGeo    :(NSString*)addressString;

- (void) urlAction:(NSNotification *)notif;

@end