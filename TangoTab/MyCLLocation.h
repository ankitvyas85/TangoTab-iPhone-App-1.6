//
//  MyCLLocation.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


@class AppDelegate;

@protocol MyCLLocationDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


@interface MyCLLocation : NSObject <CLLocationManagerDelegate,NSXMLParserDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CLGeocoder *myGeocoder;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property BOOL haveAllredyUpdate;
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property BOOL failed;

@property (nonatomic, retain) NSString *currentelement;
@property (nonatomic, retain) NSMutableString *checkinstatusmessage;

//- (void) parseXML:(NSString *) xmlString;
//- (void) sendASIHTTPRequest:(NSURL*)serverURLs;
//- (void) updateWithEvent:(NSString *)event;

//-(void) autochekin :(CLLocationManager*)mana region:(CLRegion *)re;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (void) stop;

@end
