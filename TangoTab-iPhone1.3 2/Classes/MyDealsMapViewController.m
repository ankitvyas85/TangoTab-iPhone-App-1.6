//
//  MyDealsMapViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 24/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDealsMapViewController.h"
#import "MyDealsViewController.h"
#import "AddressAnnotation.h"
#import "RedeemViewController.h"

@implementation MyDealsMapViewController


@synthesize myDealsMapArray, mapView,pointsArray; 
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	pointsArray = [[NSMutableArray alloc] init];
	//mapArray = [[NSMutableArray alloc] init];
	for(int i=0; i<[myDealsMapArray count]; i++)
	{
		stringAddress = [NSString stringWithFormat:@"%@",[[myDealsMapArray objectAtIndex:i] valueForKey:@"address"]];
		
		NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", [stringAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		NSString *locationString = [NSString stringWithContentsOfURL:url];
		
		NSArray *listItems = [locationString componentsSeparatedByString:@","];
		
		double latitude = 0.0;
		double longitude = 0.0;
		
		if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
			latitude = [[listItems objectAtIndex:2] doubleValue];
			longitude = [[listItems objectAtIndex:3] doubleValue];
		}
		else {
			//Show error
		}
		
		CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
		
		[pointsArray addObject:currentLocation];
		
	}
	
	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:mapView];
	
	
	[mapView setDelegate:self];
	
	// determine the extents of the trip points that were passed in, and zoom in to that area. 
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	
	for(int idx = 0; idx < [pointsArray count]; idx++)
	{
		CLLocation* currentLocation = [pointsArray objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[mapView setRegion:region];
	[mapView setUserInteractionEnabled:YES];
	
	
	for(int j=0; j< [pointsArray count] ; j++)
	{
		
		addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:[[pointsArray objectAtIndex:j] coordinate] title:[NSString stringWithFormat:@"%@",[[myDealsMapArray objectAtIndex:j] valueForKey:@"business_name"]] andID:j subTitle:[NSString stringWithFormat:@"%@",[[myDealsMapArray objectAtIndex:j] valueForKey:@"address"]]];
		[mapView addAnnotation:addAnnotation];
		[addAnnotation release];
		
	}
	
	
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>) annotation{
	NSString* identifier = @"Pin";
	MKPinAnnotationView *annotationView; // = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:addAnnotation reuseIdentifier:identifier] autorelease];
	
	
	annotationView.animatesDrop = YES;
	
	[annotationView setEnabled:YES];
	[annotationView setCanShowCallout:YES];
	
	UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[annotationView setRightCalloutAccessoryView:accessoryButton];
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSArray *myArray = [view.annotation.title componentsSeparatedByString:@")"];
	
	RedeemViewController *objRedeemView = [[RedeemViewController alloc] init];
	objRedeemView.redeemDic = [myDealsMapArray objectAtIndex:[[myArray objectAtIndex:0]intValue]-1];
	//objRedeemView.dealDetailDic = [placesMapArray objectAtIndex:[[myArray objectAtIndex:0]intValue]-1];
	[self.navigationController pushViewController:objRedeemView animated:YES];
	[objRedeemView release];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
	[myDealsMapArray release];
	[pointsArray release];
	[mapView release];
	[super dealloc];
	
}


@end
