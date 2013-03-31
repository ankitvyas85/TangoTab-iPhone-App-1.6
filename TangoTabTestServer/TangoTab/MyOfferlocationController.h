//
//  MyOfferlocationController.h
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol MyOfferlocationControllerDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end

@interface MyOfferlocationController : NSObject<CLLocationManagerDelegate>
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
