//
//  CheckinViewController.m
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckinViewController.h"
#import "ASIHTTPRequest.h"


@implementation CheckinViewController
@synthesize checkinDetails;
@synthesize  address_lable,dealname_lable,deal_description,timestamp_lable,asyncImageView,business_name,deal_restrictions;
//Coordinates
@synthesize reverseGeoCoder;
@synthesize myofferLocation;
@synthesize myGeocoder;
@synthesize coordinates;
@synthesize networkQueue;
@synthesize failed;
@synthesize activityIndicatorView;
@synthesize currentelement;
@synthesize checkinstatusmessage,backBarButton,ClaimButton;


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
    
    coordinates=nil;
    address_lable.text=[checkinDetails objectForKey:@"address"];
    business_name.text=[checkinDetails objectForKey:@"business_name"];
    dealname_lable.text=[checkinDetails objectForKey:@"deal_name"];
    deal_description.text=[checkinDetails objectForKey:@"deal_description"];
    deal_restrictions.text=[checkinDetails objectForKey:@"deal_restrictions"];
    checkinStatus=[[checkinDetails objectForKey:@"isconsumershownup"]integerValue];
    NSArray *dateArr = [[checkinDetails valueForKey:@"reserved_time_stamp"] componentsSeparatedByString:@" "];
    comLabel.text = [NSString stringWithFormat:@"Confirmation Code: %@",[checkinDetails valueForKey:@"con_res_id"]];
    
    
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
	//asyncImageView.x = 40;
	//asyncImageView.y = 40;
	[asyncImageView loadImageFromURL:url];
    myofferLocation=[[MyOfferlocationController alloc]init];
    myofferLocation.delegate=self;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appdelegate.isLocationUpdate == YES) {
        [ClaimButton setEnabled:NO];
    }
    if (appdelegate.isLocationUpdate == NO){
        [ClaimButton setEnabled:YES];
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
                [self reverseGeocodemethod:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, location.    coordinate.latitude,location.coordinate.longitude]]; 
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
    if (placemark!=nil) {
        [myofferLocation.locationManager stopUpdatingLocation];
    }
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

-(void)reverseGeocodemethod:(NSString *)addressString{
    addressString = [addressString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    NSArray *arr = [addressString componentsSeparatedByString:@";"];
    NSString *cordinatess=[arr objectAtIndex:2];
    cordinate = [cordinatess componentsSeparatedByString:@","];
    if ([coordinates length]==0) {
        coordinates=[NSString stringWithFormat:@"%@,%@",[cordinate objectAtIndex:0],[cordinate objectAtIndex:1]];
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
    
    @try {
        [myofferLocation.locationManager stopUpdatingLocation];
     
        AppDelegate *appdelegete=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        
            NSString *serviceURL = [NSString stringWithFormat:@"%@/mydeals/checkin?consumerresId=%@&name=%@ %@&restname=%@&dealname=%@&dealdetails=%@&coordinate=%@&restEmailId=%@",SERVER_URL,[checkinDetails valueForKey:@"con_res_id"],[appdelegete.searchingradies objectForKey:@"firstname"],[appdelegete.searchingradies objectForKey:@"last_name"],[checkinDetails valueForKey:@"business_name"],[checkinDetails valueForKey:@"deal_name"],[checkinDetails valueForKey:@"deal_description"],coordinates,[checkinDetails valueForKey:@"deal_manager_emailid"]];
            NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self sendASIHTTPRequest:url];
    }
    @catch (NSException *exception) {
        
    }
}

-( void) sendASIHTTPRequest:(NSURL*)serverURLs
{
    
    if (networkQueue) {
		[networkQueue cancelAllOperations];
        [networkQueue setDelegate:nil];
	}
	failed = NO;
	[networkQueue reset];
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


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 

}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];
    @try {
        if ([checkinstatusmessage isEqualToString:@"Successfully CheckIn."]) {
            AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            appdelegate.myOffersUpdate=NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:checkinstatusmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
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
    
}
@end
