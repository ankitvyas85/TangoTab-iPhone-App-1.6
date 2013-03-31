//
//  SearchLocation.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SearchLocationDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


@interface SearchLocation : NSObject <CLLocationManagerDelegate>


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
