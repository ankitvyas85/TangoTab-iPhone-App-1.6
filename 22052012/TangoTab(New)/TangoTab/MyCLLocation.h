//
//  MyCLLocation.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol MyCLLocationDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


@interface MyCLLocation : NSObject <CLLocationManagerDelegate>


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CLGeocoder *myGeocoder;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property BOOL haveAllredyUpdate;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
