//
//  MyCLController.m
//  CoreLocation
//
//  Created by Hiteshwar Vadlamudi on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyCLController.h"
#import "TangoTabAppDelegate.h"

@implementation MyCLController

@synthesize locationManager,reverseGeoCoder;
@synthesize isLocatedGeo;
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
		self.locationManager.distanceFilter = 1000; // 1 kilometer
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
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
		[reverseGeoCoder release];
		reverseGeoCoder = nil;
	}
    else {
	reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
	reverseGeoCoder.delegate = self;
	[reverseGeoCoder start];
    isLocatedGeo = YES;
    }
	
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	
	[self.delegate locationError:error];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error1 {
	[self.delegate reverseGeoCoderError:error1];
    [reverseGeoCoder autorelease];
}

//Callback function for reverse Geo Coder. 
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isAddressForSearch == NO) {
		[self.delegate reverseGeoCoder:[NSString stringWithFormat:@"%@",placemark.postalCode]];
	}
	else {
		[self.delegate reverseGeoCoder:[NSString stringWithFormat:@"%@,%@,%@",placemark.subAdministrativeArea,placemark.administrativeArea,placemark.country]];
	}
	[reverseGeoCoder cancel];
	[reverseGeoCoder autorelease];
    isLocatedGeo = NO;
}

- (void)dealloc {
    reverseGeoCoder = nil;
    
    [self.locationManager release];
	delegate = nil;
    [super dealloc];
}

@end
