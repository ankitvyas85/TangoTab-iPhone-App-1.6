//
//  MyOfferlocationController.m
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyOfferlocationController.h"

@implementation MyOfferlocationController
@synthesize myOfferlocationManager;
@synthesize delegate;
@synthesize myGeocoder;
@synthesize haveAllredyUpdate;
@synthesize reverseGeoCoder;


- (id) init {
    
    self = [super init];
    
    if (self != nil) {
        self.myOfferlocationManager = [[[CLLocationManager alloc] init] autorelease];
        self.myOfferlocationManager.delegate = self;
        [self.myOfferlocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
   //     [self.myOfferlocationManager setDistanceFilter:403.0f];
        [self.myOfferlocationManager startUpdatingLocation];
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if([self.delegate conformsToProtocol:@protocol(MyOfferlocationControllerDelegate)])
    {
        [self.delegate updateGpsStats:newLocation];
    }
    // test the age of the location measurement to determine if the measurement is cached
 //   NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
//    if (locationAge > 5.0) return;
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;

    if (newLocation.horizontalAccuracy <= 1609) {
        @try {
            
            if([self.delegate conformsToProtocol:@protocol(MyOfferlocationControllerDelegate)])
            {
                [self.delegate myOfferlocationUpdate:newLocation];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
    
 
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	if([self.delegate conformsToProtocol:@protocol(MyOfferlocationControllerDelegate)]) { 
        [self.delegate myOfferlocationError:error];
    }
}


- (void)dealloc {
    
    [super dealloc];
}

@end
