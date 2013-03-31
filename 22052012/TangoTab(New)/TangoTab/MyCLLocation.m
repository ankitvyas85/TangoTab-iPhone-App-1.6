//
//  MyCLLocation.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCLLocation.h"

@implementation MyCLLocation
@synthesize locationManager;
@synthesize delegate;
@synthesize myGeocoder;
@synthesize haveAllredyUpdate;
@synthesize reverseGeoCoder;

- (id) init {
    
    self = [super init];
    
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [self.locationManager setDistanceFilter:1000.0f];
        [self.locationManager startUpdatingLocation];
    }
   
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    @try {

        if([self.delegate conformsToProtocol:@protocol(MyCLLocationDelegate)]) 
        {  
            [self.delegate locationUpdate:newLocation];
        }
    }
    @catch (NSException *exception) {
        
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	if([self.delegate conformsToProtocol:@protocol(MyCLLocationDelegate)]) { 
        [self.delegate locationError:error];
    }
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

- (void)dealloc {
    
    [super dealloc];
}

@end
