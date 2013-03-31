//
//  SearchMapViewcontroller.h
//  TangoTab
//
//  Created by Sirisha G on 20/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "SearchDetailViewController.h"
#import "AddressAnnotation.h"


@class AddressAnnotation;
@class AppDelegate;
@class SearchDetailViewController;

@interface SearchMapViewcontroller : TrackedUIViewController <MKMapViewDelegate,NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableArray *placesMapArray,*pointsArray,*mapcoordinate;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;
@property (nonatomic, retain) AddressAnnotation *addAnnotation; 
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) SearchDetailViewController *searchDetailVCtrl;
@property (nonatomic, retain) NSArray *currentArray, *listItems;
@property (nonatomic, assign) int pinID;
@property (nonatomic, assign) double latitude ,longitude;

@property (nonatomic,retain)NSMutableString *currentElement;

-(void)parsecoordinates:(NSURL *)parseurl;
@end
