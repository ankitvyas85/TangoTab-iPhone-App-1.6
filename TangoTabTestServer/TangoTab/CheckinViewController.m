//
//  CheckinViewController.m
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckinViewController.h"



@implementation CheckinViewController
@synthesize checkinDetails;
@synthesize  address_lable,dealname_lable,deal_description,timestamp_lable,asyncImageView,business_name,deal_restrictions;
//Coordinates
@synthesize reverseGeoCoder;
@synthesize myofferLocation;
@synthesize myGeocoder;
@synthesize coordinates;
@synthesize networkQueue;
@synthesize failed,autoCheckStatus;
@synthesize activityIndicatorView;
@synthesize currentelement;
@synthesize checkinstatusmessage,backBarButton,CheckInButton,sharedDelegate;


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
    sharedDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    autoCheckStatus = NO;
    myofferLocation=[[MyOfferlocationController alloc]init];
    myofferLocation.delegate=self; 
    UIImage *shuffleButtonDisabledImage = [UIImage imageNamed:@"back_button.png"];
    UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shuffleButton setImage:shuffleButtonDisabledImage forState:UIControlStateNormal];
    shuffleButton.frame = CGRectMake(0, 0, shuffleButtonDisabledImage.size.width, shuffleButtonDisabledImage.size.height);
    [shuffleButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside]; 
    
    UIBarButtonItem *shuffleBarItem = [[UIBarButtonItem alloc]	initWithCustomView:shuffleButton];
    
    backBarButton.leftBarButtonItem = shuffleBarItem;
    
    coordinates=nil;
    address_lable.text=[checkinDetails objectForKey:@"address"];
    business_name.text=[checkinDetails objectForKey:@"business_name"];
    dealname_lable.text=[checkinDetails objectForKey:@"deal_name"];
    deal_description.text=[checkinDetails objectForKey:@"deal_description"];
    deal_restrictions.text=[checkinDetails objectForKey:@"deal_restrictions"];
    checkinStatus=[[checkinDetails objectForKey:@"isconsumershownup"]integerValue];

    comLabel.text = [NSString stringWithFormat:@"Confirmation Code: %@",[checkinDetails valueForKey:@"con_res_id"]];
    NSArray *dateArr = [[checkinDetails valueForKey:@"reserved_time_stamp"] componentsSeparatedByString:@" "];
    
    NSDateFormatter *dff = [[NSDateFormatter alloc] init];
    [dff setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStrig = [NSString stringWithFormat:@"%@",[dateArr objectAtIndex:0]];
    NSDate *date = [dff dateFromString:dateStrig];
    
    NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
    [dateformstring setDateFormat:@"EEE, MMM dd yyyy"];
    NSString *resultDate4 = [dateformstring stringFromDate:date];
    
    
	[timestamp_lable setText:[NSString stringWithFormat:@"%@ %@ to %@",resultDate4,[checkinDetails valueForKey:@"start_time"],[checkinDetails valueForKey:@"end_time"]]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"image_url"]];
	NSURL *url = [NSURL URLWithString:urlString];
	[asyncImageView loadImageFromURL:url];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if (sharedDelegate.isLocationUpdate == YES) {
        [CheckInButton setEnabled:NO];
    }
    if (sharedDelegate.isLocationUpdate == NO){
        [CheckInButton setEnabled:YES];
    }
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)locationUpdate:(CLLocation *)location
{
    
    if (NSClassFromString(@"CLGeocoder")){
        
        myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [self reverseGeocodemethod:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, location.coordinate.latitude,location.coordinate.longitude]]; 
            }
            else if (error == nil &&[placemarks count] == 0){ 
            }
            else if (error != nil){
            } }];
    }
    else {
        reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
        reverseGeoCoder.delegate = self;
        [reverseGeoCoder start];
    }
}

- (void)locationError:(NSError *)error
{
    [myofferLocation.locationManager stopUpdatingLocation];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark 
{
    @try {
        [self reverseGeocodemethod:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, placemark.coordinate.latitude,placemark.coordinate.longitude]];
    }
    @catch (NSException *exception) {
        
    }
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

-(void)reverseGeocodemethod:(NSString *)addressString {
    addressString = [addressString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    NSArray *arr = [addressString componentsSeparatedByString:@";"];
    NSString *cordinatess= [arr objectAtIndex:2];

    cordinate = [cordinatess componentsSeparatedByString:@","];
    if ([coordinates length]==0) {
        coordinates=[NSString stringWithFormat:@"%@,%@",[cordinate objectAtIndex:0],[cordinate objectAtIndex:1]];
        NSString *dateStrig = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"current_date"]];    
        NSArray *datArray = [dateStrig componentsSeparatedByString:@" "];
        
        NSString *dateStrig2 = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"reserved_time_stamp"]];    
        NSArray *datArray2 = [dateStrig2 componentsSeparatedByString:@" "];
        
        if ([[datArray objectAtIndex:0] isEqualToString:[datArray2 objectAtIndex:0]]) {
        
            float latitude = [[checkinDetails valueForKey:@"latitude"] floatValue];
            float longitude = [[checkinDetails valueForKey:@"longitude"] floatValue];
            float currlatitude =  [[cordinate objectAtIndex:0] floatValue];
            float currlongitude = [[cordinate objectAtIndex:1] floatValue];
            
            NSLog(@"la:%f Lo:%f",currlatitude,currlongitude);
            NSLog(@"la:%f Lo:%f",latitude,longitude);
            CLLocation *myOfferLocaion = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude]; 
            CLLocation *currentLocaion = [[CLLocation alloc] initWithLatitude:currlatitude longitude:currlongitude];                      
            CLLocationDistance meters = [currentLocaion distanceFromLocation:myOfferLocaion]/1000;
            NSLog(@"%f",meters);
            if (meters < 405) {
                if ([[sharedDelegate.searchingradies objectForKey:@"autocheckin"] isEqualToString:@"YES"]) {
                    if (!checkinStatus) {
                        autoCheckStatus = YES;
                        [self autocheckin:@"Y" autocheckDetail:nil userName:nil];  
                    }
                }
            }
        }
        
    }
    [coordinates copy];
}

-(IBAction)checkin:(id)sender{
    
    NSError *error = nil;
    if (![[GANTracker sharedTracker] trackEvent:@"Check In Button"
                                         action:@"TrackEvent"
                                          label:@"Check In"
                                          value:-1
                                      withError:&error]) {
        NSLog(@"Error Occured");
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"MyOffers",
                                @"Check In Button",
                                nil];
    [FlurryAnalytics logEvent:@"Check In" withParameters:dictionary];
    
    @try {
        [myofferLocation.locationManager stopUpdatingLocation];
     
        [self autocheckin:@"N" autocheckDetail:nil userName:nil];
           
    }
    @catch (NSException *exception) {
        
    }
}

- (void) autocheckin:(NSString*)autoStatus autocheckDetail:(NSDictionary*)temDict userName:(NSString *)name
{
    NSString *serviceURL;
    if (temDict) {
        serviceURL  = [NSString stringWithFormat:@"%@/mydeals/checkin?consumerresId=%@&name=%@&restname=%@&dealname=%@&dealdetails=%@&coordinate=%@&restEmailId=%@&autocheckin=%@",SERVER_URL,[temDict valueForKey:@"con_res_id"],name,[temDict valueForKey:@"business_name"],[temDict valueForKey:@"deal_name"],[temDict valueForKey:@"deal_description"],coordinates,[temDict valueForKey:@"deal_manager_emailid"],autoStatus];
    }
    else {
        serviceURL  = [NSString stringWithFormat:@"%@/mydeals/checkin?consumerresId=%@&name=%@ %@&restname=%@&dealname=%@&dealdetails=%@&coordinate=%@&restEmailId=%@&autocheckin=%@",SERVER_URL,[checkinDetails valueForKey:@"con_res_id"],[sharedDelegate.searchingradies objectForKey:@"firstname"],[sharedDelegate.searchingradies objectForKey:@"last_name"],[checkinDetails valueForKey:@"business_name"],[checkinDetails valueForKey:@"deal_name"],[checkinDetails valueForKey:@"deal_description"],coordinates,[checkinDetails valueForKey:@"deal_manager_emailid"],autoStatus];
    }
    
    NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",url);
    [self sendASIHTTPRequest:url];
}

-( void) sendASIHTTPRequest:(NSURL*)serverURLs
{
    
//    if (networkQueue) {
//		[networkQueue cancelAllOperations];
//        [networkQueue setDelegate:nil];
//	}
	failed = NO;
	//[networkQueue reset];
    networkQueue = [[ASINetworkQueue alloc] init];
	[networkQueue setRequestDidFinishSelector:@selector(FetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(FetchFailed:)];
	[networkQueue setDelegate:self];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:serverURLs];
    [request setTimeOutSeconds:60];
    [networkQueue addOperation:request];
    [networkQueue go];
    [self showActivityIndicatorView];
}
- (void)FetchComplete:(ASIHTTPRequest *)request 
{
    NSString *respose = [request responseString];
    [self parseXML:respose];
}

- (void)FetchFailed:(ASIHTTPRequest *)request
{
    [self stopActivityIndicatorView];
    if (!failed) {
        NSError *error = [request error];
        NSString *description =[NSString stringWithString:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
        if([description isEqualToString:@"Cannot connect to TangoTab service. This might be due to your data connection. If this problem persists, please notify TangoTab at help@tangotab.com."] || [description isEqualToString:@"It appears there is no data connection, please check your settings."])
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alertView show];
        }
        else if (![description isEqualToString:@"The request was cancelled"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        failed = YES;
    }
}

-(void) parseXML:(NSString *) xmlString
{
    @try {
        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        
        [parser setDelegate:self];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
        
    }
    @catch (NSException *exception) {
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentelement=[[NSMutableString alloc]init];
    currentelement=[elementName mutableCopy];
    if ([elementName isEqualToString:@"message"]) {
        checkinstatusmessage=[[NSMutableString alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentelement isEqualToString:@"message"]) {
        [checkinstatusmessage appendString:terstring];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName { 

}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];
    @try {
        if ([checkinstatusmessage isEqualToString:@"Successfully CheckIn."]) {
            
            sharedDelegate.myOffersUpdate=NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            if (autoCheckStatus) {
                NSArray *convString = [checkinstatusmessage componentsSeparatedByString:@"."];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[convString objectAtIndex:0] message:[convString objectAtIndex:1] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                autoCheckStatus = NO;
            }
            else {
                if (sharedDelegate.isNotAttended == YES || sharedDelegate.isAttended == YES) {
                    sharedDelegate.isNotAttended = NO;
                    sharedDelegate.isAttended = NO;
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:checkinstatusmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, 320, 480)];
		[self.view addSubview:activityIndicatorView];
	}
}

-(void)stopActivityIndicatorView{
    
	[activityIndicatorView removeActivityIndicator];
	
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)dealloc{
    [networkQueue cancelAllOperations];
    [networkQueue release];
    [reverseGeoCoder release];
    [activityIndicatorView release];
    [checkinstatusmessage release];
    [CheckInButton release];
    [currentelement release];
    
}
@end
