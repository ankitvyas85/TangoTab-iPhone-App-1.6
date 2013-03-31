//
//  LocationController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 12/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@protocol LocationControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
-(void)reverseGeoCoder:(NSString *)addressString;
-(void)reverseGeoCoderError:(NSError *)error;
@end

@interface LocationController : NSObject<CLLocationManagerDelegate, MKReverseGeocoderDelegate> {

	CLLocationManager *locationManager;
	MKReverseGeocoder *reverseGeoCoder;
	id delegate;
	
}

@property     BOOL isLocatedGeo;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeoCoder;
@property (nonatomic, assign) id  delegate;

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
