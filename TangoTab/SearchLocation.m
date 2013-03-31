//
//  SearchLocation.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchLocation.h"

@implementation SearchLocation
@synthesize locationManager;
@synthesize delegate;


- (id) init {
    
    self = [super init];
    
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDistanceFilter:403.0f];
        [self.locationManager startUpdatingLocation];
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if([self.delegate conformsToProtocol:@protocol(SearchLocationDelegate)]) 
    {  
        [self.delegate locationUpdate:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	if([self.delegate conformsToProtocol:@protocol(SearchLocationDelegate)]) { 
        [self.delegate locationError:error];
    }
}



- (void)dealloc {
    
    [super dealloc];
}


@end
