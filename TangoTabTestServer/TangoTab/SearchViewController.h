//
//  SearchViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




#import "defines.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "SearchCustomCell.h"
#import "NearMeDetailViewController.h"
#import "SearchDetailViewController.h"
#import "AsyncImageView.h"
#import "SearchLocation.h"
#import "SearchMapViewcontroller.h"
#import "FlurryAnalytics.h"
#import "EasyTracker.h"
#import "GANTracker.h"

@class ASIHTTPRequest;
@class FlurryAnalytics;
@class ASINetworkQueue;
@class SearchDetailViewController;

@interface SearchViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,UISearchDisplayDelegate, UISearchBarDelegate,SearchLocationDelegate,MKReverseGeocoderDelegate>


@property (nonatomic, retain) IBOutlet UITableView *searchTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *restaurantSearchBar,*addressSearchBar;

@property (nonatomic, retain) UIButton *showMore;
@property (nonatomic, retain) NSMutableArray *searchArray,*imagesArray;
@property (nonatomic, retain) NSMutableDictionary *searchDetails,*currentAddressDict;
@property (nonatomic, retain) NSMutableString *noOfdeals,*dealsfrom,*cuisine_type_id,*driving_distance,*business_name,*deal_name,*image_url,*rest_deal_restrictions,*deal_description,*rest_deal_availablestart_date,*rest_deal_start_date,*rest_deal_end_date,*available_start_time,*available_end_time,*available_week_days,*deal_credit_value,*location_rest_address,*address,*no_deals_available;

@property (nonatomic, retain) UILabel *nodata_Lable;
@property (nonatomic, retain) NSString *latandlng,*currentElement,*dealid,*serverURL;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property (nonatomic, retain) CLGeocoder *myGeocoder;


@property (nonatomic, retain) SearchLocation *searchLocation;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) Mapviewcontroller *mapViewCtrl;
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) NearMeDetailViewController *nearmeDetailVCtrl;
@property (nonatomic,retain)  SearchDetailViewController *searchDetailview;

@property int pageIndex;
@property int noOfOffers;


@property BOOL failed;


- (void) parseXML:(NSString *) xmlString;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;

- (void) locationUpdate:(CLLocation *)location;
- (void) locationError :(NSError *)error;
- (void) reverseGeo    :(NSString*)addressString;

- (void) getValuesFromLocation;
- (void) getValuesFromServer;

@end
