//
//  SearchLocationController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 14/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchLocationController.h"
#import "TangoTabAppDelegate.h"

@implementation SearchLocationController
@synthesize locationManager,reverseGeoCoder;
@synthesize delegate;

- (id) init {
    self = [super init];
    if (self != nil) {
		if (locationManager) {
			[locationManager release];
			locationManager = nil;
		}
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
		self.locationManager.distanceFilter = 1000;  // 1 kilometer
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	}
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	[self.delegate locationUpdate:newLocation];
	
	if (reverseGeoCoder) {
		[reverseGeoCoder release];
		reverseGeoCoder = nil;
	}
	reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
	reverseGeoCoder.delegate = self;
	[reverseGeoCoder start];
	
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error1 {
	[self.delegate reverseGeoCoderError:error1];
}

//Callback function for reverse Geo Coder. 
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	
	[self.delegate reverseGeoCoder:[NSString stringWithFormat:@"%@,%@",placemark.subAdministrativeArea,placemark.postalCode]];
	
	[geocoder cancel];
}

- (void)dealloc {
    [self.locationManager release];
	[reverseGeoCoder release];
	delegate = nil;
    [super dealloc];
}

@end
