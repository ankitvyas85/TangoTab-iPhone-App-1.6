//
//  Mapviewcontroller.h
//  TangoTab
//
//  Created by Sirisha G on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NearMeDetailViewController.h"
#import "AppDelegate.h"
#import "AddressAnnotation.h"
#import "EasyTracker.h"
#import "GANTracker.h"


@class AddressAnnotation;
@class AppDelegate;
@class NearMeDetailViewController;

@interface Mapviewcontroller : TrackedUIViewController <MKMapViewDelegate,NSXMLParserDelegate>


@property (nonatomic, retain) NSMutableArray *placesMapArray,*pointsArray,*mapcoordinate;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;
@property (nonatomic, retain) AddressAnnotation *addAnnotation; 
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) NearMeDetailViewController *nearmeDetailVCtrl;
@property (nonatomic, retain) NSArray *currentArray, *listItems;
@property (nonatomic, assign) int pinID;
@property (nonatomic, assign) double latitude ,longitude;

@property (nonatomic,retain)NSMutableString *currentElement;

-(void)parsecoordinates:(NSURL *)parseurl;

@end
