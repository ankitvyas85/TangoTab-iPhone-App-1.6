//
//  MyDealsMapViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 24/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EasyTracker.h"
@class AddressAnnotation;

@interface MyDealsMapViewController : TrackedUIViewController <MKMapViewDelegate>{
	
	NSMutableArray *myDealsMapArray;
	MKMapView *mapView;
	NSString *stringAddress;
	AddressAnnotation *addAnnotation;
	NSMutableArray *pointsArray;
	int pinID;
	
}

@property (nonatomic, retain) NSMutableArray *myDealsMapArray;
@property (nonatomic, retain) NSMutableArray *pointsArray;
@property (nonatomic, retain) MKMapView *mapView;

@end
