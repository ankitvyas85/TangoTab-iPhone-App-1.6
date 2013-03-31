//
//  MyOffersMapViewController.h
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"

@class AddressAnnotation;

@interface MyOffersMapViewController : TrackedUIViewController<MKMapViewDelegate,NSXMLParserDelegate>
@property (nonatomic, retain) NSMutableArray *myoffersMapArray,*pointsArray;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;
@property (nonatomic, retain) AddressAnnotation *addAnnotation; 
@property (nonatomic, retain) NSArray *currentArray,*listItems;
@property (nonatomic, assign) int pinID;
@property (nonatomic, assign) double latitude ,longitude;
@property(nonatomic,retain)NSMutableString *currentElement;


-(void)parsecoordinates:(NSURL *)parseurl;


@end
