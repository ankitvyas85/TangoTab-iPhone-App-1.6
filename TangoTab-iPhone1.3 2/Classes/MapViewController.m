//
//  MapViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "PlacesViewController.h"
#import "AddressAnnotation.h"
#import "WantItViewController.h"
#import "TangoTabAppDelegate.h"

@implementation MapViewController
@synthesize placesMapArray, mapView,pointsArray,addAnnotation,pinID; 
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
	for(int i=0; i<[placesMapArray count]; i++)
	{
		NSString *stringAddress = [NSString stringWithFormat:@"%@",[[placesMapArray objectAtIndex:i] valueForKey:@"address"]];
		
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
		if (addAnnotation) {
			[addAnnotation release];
			addAnnotation = nil;
		}			
		addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:[[pointsArray objectAtIndex:j] coordinate] title:[NSString stringWithFormat:@"%@",[[placesMapArray objectAtIndex:j] valueForKey:@"business_name"]] andID:j subTitle:[NSString stringWithFormat:@"%@",[[placesMapArray objectAtIndex:j] valueForKey:@"address"]]];
		[mapView addAnnotation:addAnnotation];
		
	}
		
	
}

-(void)viewWillAppear:(BOOL)animated{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.wantToGoBack) {
		[self.navigationController popViewControllerAnimated:NO];
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
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isWantToPopInMap) {
		appDelegate.isWantToPopInMap = NO;
		[self.navigationController popViewControllerAnimated:YES];
		
	}
	else {
		
		NSArray *myArray = [view.annotation.title componentsSeparatedByString:@")"];
		
		appDelegate.wantItDic = [placesMapArray objectAtIndex:[[myArray objectAtIndex:0]intValue]-1];
		
		WantItViewController *wantItObj = [[WantItViewController alloc] init];
		
		[self.navigationController pushViewController:wantItObj animated:YES];
		[wantItObj release];
	}
		
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
    [addAnnotation release];
	[placesMapArray release];
	[pointsArray release];
	[mapView release];
	[super dealloc];
	
}


@end
