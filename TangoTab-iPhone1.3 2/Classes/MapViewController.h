//
//  MapViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EasyTracker.h"
@class AddressAnnotation;
@interface MapViewController : TrackedUIViewController <MKMapViewDelegate>{

	NSMutableArray *placesMapArray;
	 MKMapView *mapView;
	AddressAnnotation *addAnnotation;
	NSMutableArray *pointsArray;
	int pinID;

}

@property (nonatomic, retain) NSMutableArray *placesMapArray;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) AddressAnnotation *addAnnotation;
@property (nonatomic, retain) NSMutableArray *pointsArray;
@property (nonatomic, assign) int pinID;

@end
