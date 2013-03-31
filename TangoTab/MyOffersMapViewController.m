//
//  MyOffersMapViewController.m
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "defines.h"
#import "MyOffersMapViewController.h"
#import "JSON.h"

@implementation MyOffersMapViewController
@synthesize myoffersMapArray,mapView,pointsArray,addAnnotation,pinID,currentArray,backBarButton,listItems,longitude,latitude,currentElement;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *shuffleButtonDisabledImage = [UIImage imageNamed:@"back_button.png"];
    UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shuffleButton setImage:shuffleButtonDisabledImage forState:UIControlStateNormal];
    
    shuffleButton.frame = CGRectMake(0, 0, shuffleButtonDisabledImage.size.width, shuffleButtonDisabledImage.size.height);
    [shuffleButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside]; 
    UIBarButtonItem *shuffleBarItem = [[UIBarButtonItem alloc]	initWithCustomView:shuffleButton];
   
    backBarButton.leftBarButtonItem = shuffleBarItem;
    
    pointsArray  = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[myoffersMapArray count]; i++)
    {
       NSString *stringAddress = [NSString stringWithFormat:@"%@",[[myoffersMapArray objectAtIndex:i] valueForKey:@"address"]];
		
		NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [stringAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:urlString];
		SBJSON *parser = [[SBJSON alloc] init];
		NSURLRequest *request1 = [NSURLRequest requestWithURL:url];
		
		// Perform request and get JSON back as a NSData object
		NSData *response = [NSURLConnection sendSynchronousRequest:request1 returningResponse:nil error:nil];
		
		// Get JSON as a NSString from NSData response
		NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		NSArray *statuses = [parser objectWithString:json_string error:nil];
		
		NSDictionary *dV =  [[[[statuses valueForKey:@"results"] objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
		latitude = [[dV valueForKey:@"lat"] floatValue];
		longitude = [[dV valueForKey:@"lng"] floatValue];
		
		[parser release];

        
        CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
        
        [pointsArray addObject:currentLocation];
    }

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
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLon + minLon) / 2.0), 1000.0, 1000.0);
    region.span.latitudeDelta = MAX(region.span.latitudeDelta, (maxLat - minLat) * 1.05);
    region.span.longitudeDelta = MAX(region.span.longitudeDelta, (maxLon - minLon) * 1.05);
    
    [mapView setRegion:region];
    [mapView setUserInteractionEnabled:YES];
    mapView.showsUserLocation=YES;
    for(int j=0; j< [pointsArray count] ; j++)
    {
        if (addAnnotation) {
            [addAnnotation release];
            addAnnotation = nil;
        }
        
        addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:[[pointsArray objectAtIndex:j] coordinate] title:[NSString stringWithFormat:@"%@",[[myoffersMapArray objectAtIndex:j] valueForKey:@"business_name"]] andID:j subTitle:[NSString stringWithFormat:@"%@",[[myoffersMapArray objectAtIndex:j] valueForKey:@"address"]]];
        [mapView addAnnotation:addAnnotation];
        
    }
}

-(void)parsecoordinates:(NSURL *)parseurl{
    NSData *data=[NSData dataWithContentsOfURL:parseurl];
    NSXMLParser *parser=[[NSXMLParser alloc]initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement=[[NSMutableString alloc]init];
    currentElement=[elementName copy];
	if ([elementName isEqualToString:@"Response"]) {
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentElement isEqualToString:@"coordinates"]) {
        if ([terstring length]!=0) {
            listItems = [terstring componentsSeparatedByString:@","];
            latitude = [[listItems objectAtIndex:1]doubleValue];
            longitude = [[listItems objectAtIndex:0]doubleValue];
            
        }
        
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    if ([elementName isEqualToString:@"Response"]) {
        
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    
    
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>) annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;  //r
    [mapView.userLocation setTitle:@"I am here"];
    NSString* identifier = @"Pin";
    MKPinAnnotationView *annotationView; 
    annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:addAnnotation reuseIdentifier:identifier] autorelease];
    
    annotationView.pinColor = MKPinAnnotationColorPurple;
    annotationView.animatesDrop = YES;
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [annotationView setRightCalloutAccessoryView:accessoryButton];
    return annotationView;

}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    @try {
        NSArray *myArray = [view.annotation.title componentsSeparatedByString:@")"];
        
        CheckinViewController *checkin = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:[NSBundle mainBundle]];
        checkin.checkinDetails = [myoffersMapArray objectAtIndex:[[myArray objectAtIndex:0]intValue]-1];
        [self.navigationController pushViewController:checkin animated:YES];
        
    }
    @catch (NSException *exception) {
        
    }
    
}

-(void)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [addAnnotation release];
	[myoffersMapArray release];
	[pointsArray release];
	[mapView release];
}
@end
