//
//  CheckinViewController.h
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"
#import "EasyTracker.h"
#import "GANTracker.h"
#import "AsyncImageView.h"
#import "MyOfferlocationController.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "FlurryAnalytics.h"
#import "ActivityIndicatorView.h"
#import "AppDelegate.h"

@class AppDelegate;
@class ActivityIndicatorView;
@class AppDelegate;
@class FlurryAnalytics;
@class ASINetworkQueue;


@interface CheckinViewController : TrackedUIViewController<MKReverseGeocoderDelegate,MyOfferlocationControllerDelegate,NSXMLParserDelegate>
{
    int checkinStatus;
    NSDictionary *d;
    NSArray *cordinate;
    IBOutlet UILabel *comLabel;
    int gpsUpdateCount;
}
@property(nonatomic,retain) IBOutlet UIButton  *CheckInButton;

@property(nonatomic,retain)NSMutableDictionary *checkinDetails;
@property(nonatomic,retain)IBOutlet UILabel *address_lable,*dealname_lable,*deal_description,*timestamp_lable,*business_name,*deal_restrictions;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property (nonatomic, retain) CLGeocoder *myGeocoder;
@property (nonatomic, retain) NSString *coordinates;
@property (nonatomic, retain) NSString *lastCoordinates;
@property (nonatomic, assign) NSMutableString *currentelement,*checkinstatusmessage;
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet AsyncImageView *asyncImageView;
@property (nonatomic, retain) MyOfferlocationController *myofferLocation;
@property (nonatomic, assign) BOOL failed,autoCheckStatus,manuCheck;
@property CLLocationDistance distanceFromDeal;
@property (nonatomic, retain) IBOutlet UILabel *gpsAccuracy;
@property (nonatomic, retain) IBOutlet UILabel *gpsCurrentLocation;
@property (nonatomic, retain) IBOutlet UILabel *gpsDistanceToDeal;
@property (nonatomic, retain) IBOutlet UILabel *gpsUpdateCounter;

- (void) autocheckin:(NSString*)autoStatus autocheckDetail:(NSDictionary*)temDict userName:(NSString*)name;
- (void) reverseGeocodemethod:(NSString *)addressString;
- (void) parseXML:(NSString *) xmlString;
- (void) sendASIHTTPRequest:(NSURL*)serverURLs;
- (void) showActivityIndicatorView;
- (void) stopActivityIndicatorView;
- (void) updateGpsStats:(CLLocation *)location;
@end
