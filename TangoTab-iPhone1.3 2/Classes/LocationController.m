//
//  LocationController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 12/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"
#import "TangoTabAppDelegate.h"

@implementation LocationController
@synthesize locationManager,reverseGeoCoder;
@synthesize delegate;
@synthesize isLocatedGeo;

- (id) init {
    self = [super init];
    if (self != nil) {
		if (locationManager) {
			[locationManager release];
			locationManager = nil;
		}
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
		self.locationManager.distanceFilter = kCLDistanceFilterNone; //1000;  // 1 kilometer
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //kCLLocationAccuracyKilometer;
	}
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.currentLocation = newLocation;
	[self.delegate locationUpdate:newLocation];
	
	if (isLocatedGeo) {
        [reverseGeoCoder cancel];
		[reverseGeoCoder autorelease];
		
	}
    else {
	reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
	reverseGeoCoder.delegate = self;
	[reverseGeoCoder start];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
    [reverseGeoCoder autorelease];

}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error1 {
	[self.delegate reverseGeoCoderError:error1];
	[reverseGeoCoder autorelease];
}

//Callback function for reverse Geo Coder. 
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isAddressForSearch == NO) {
		[self.delegate reverseGeoCoder:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, placemark.coordinate.latitude, placemark.coordinate.longitude]];
	}
	else {
		[self.delegate reverseGeoCoder:[NSString stringWithFormat:@"%@,%@,%@",placemark.subAdministrativeArea,placemark.administrativeArea,placemark.country]];
	}
	[reverseGeoCoder cancel];
	[reverseGeoCoder release];
    isLocatedGeo = NO;

}

- (void)dealloc {
    [self.locationManager release];
	delegate = nil;
    [super dealloc];
}

@end
