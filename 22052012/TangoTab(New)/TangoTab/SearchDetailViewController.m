//
//  SearchDetailViewController.m
//  TangoTab
//
//  Created by Sirisha G on 20/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "SearchDetailViewController.h"
@implementation SearchDetailViewController
@synthesize sharedDelegate;
@synthesize myImageView,restaurantNameLabel,restaurantLocationLabel,dealNameLabel,creditValueLabel,cuisineTypeIdLabel,dateAndTimeLabel,dealTimeButton,dealDescriptionLabel,dealRestriction;
@synthesize imageURL;
@synthesize searchmapViewCtrl;
@synthesize networkQueue;
@synthesize failed;
@synthesize currentelement;
@synthesize dealStatus;
@synthesize activityIndicatorView;
@synthesize backBarButton;

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
    sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImage *shuffleButtonDisabledImage = [UIImage imageNamed:@"back_button.png"];
    UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shuffleButton setImage:shuffleButtonDisabledImage forState:UIControlStateNormal];
    shuffleButton.frame = CGRectMake(0, 0, shuffleButtonDisabledImage.size.width, shuffleButtonDisabledImage.size.height);
    [shuffleButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside]; 
    
    UIBarButtonItem *shuffleBarItem = [[UIBarButtonItem alloc]	initWithCustomView:shuffleButton];
    
    backBarButton.leftBarButtonItem = shuffleBarItem;
    
    NSString *urlString = [sharedDelegate.nearMeDetailDict valueForKey:@"image_url"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    self.imageURL = url;
    
    [self.myImageView loadImageFromURL:self.imageURL];
    [restaurantNameLabel setText:[sharedDelegate.nearMeDetailDict valueForKey:@"business_name"]];
    [restaurantLocationLabel setText:[sharedDelegate.nearMeDetailDict valueForKey:@"location_rest_address"]];
    [dealNameLabel setText:[sharedDelegate.nearMeDetailDict valueForKey:@"deal_name"]];
    [creditValueLabel setText:[NSString stringWithFormat:@"$%@",[sharedDelegate.nearMeDetailDict valueForKey:@"deal_credit_value"]]];
    //[cuisineTypeIdLabel setText:[sharedDelegate.nearMeDetailDict valueForKey:@"cuisine_type_id"]];
    [dealDescriptionLabel setText:[sharedDelegate.nearMeDetailDict valueForKey:@"deal_description"]];
    [dealRestriction setText:[sharedDelegate.nearMeDetailDict valueForKey:@"rest_deal_restrictions"]];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *dateStrig = [NSString stringWithFormat:@"%@",[sharedDelegate.nearMeDetailDict valueForKey:@"rest_deal_availablestart_date"]];
    NSDate *date = [dateFormatter dateFromString:dateStrig];
    
    NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
    [dateformstring setDateFormat:@"EEE, MMM dd yyyy"];
    NSString *resultDate = [dateformstring stringFromDate:date];
    [dateAndTimeLabel setText:[NSString stringWithFormat:@"%@, %@ to %@",resultDate,[sharedDelegate.nearMeDetailDict valueForKey:@"available_start_time"],[sharedDelegate.nearMeDetailDict valueForKey:@"available_end_time"]]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    sharedDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=YES;
}

-(void)back:(id)sender{
    sharedDelegate.nearmedidSele= NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)fixDealButtonClicked:(id)sender{
    NSError *error = nil;
    if (![[GANTracker sharedTracker] trackEvent:@"Claim Now Button"
                                         action:@"TrackEvent"
                                          label:@"Claim Now"
                                          value:-1
                                      withError:&error]) {
        NSLog(@"Error Occured");
    }
    
    @try {  
        NSDateFormatter *dff = [[NSDateFormatter alloc] init];
        
        [dff setDateFormat:@"YYYY-MM-dd"];
        NSString *dateStrig = [NSString stringWithFormat:@"%@",[sharedDelegate.nearMeDetailDict valueForKey:@"rest_deal_availablestart_date"]];
        NSDate *date = [dff dateFromString:dateStrig];
        
        NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
        [dateformstring setDateFormat:@"EEE, MMM dd yyyy"];
        NSString *resultDate1 = [dateformstring stringFromDate:date];
        
        NSString *dateandtime = [NSString stringWithFormat:@"%@ %@",resultDate1,[sharedDelegate.nearMeDetailDict valueForKey:@"available_start_time"]];
        
        [dff release];
        [dateformstring release];
        
        NSString *serviceURL = [NSString stringWithFormat:@"%@/deals/insertdeal?emailId=%@&timestamp=%@&dealId=%@&orderedtimestamp=",SERVER_URL,[sharedDelegate.userdetails valueForKey:@"login"],dateandtime,[sharedDelegate.nearMeDetailDict valueForKey:@"id"]];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        dealStatus=[[NSMutableString alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentelement isEqualToString:@"message"]) {
        [dealStatus appendString:terstring];
    }
    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];
    if ([dealStatus isEqualToString:@"You have successfully claimed this offer."]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"TangoTab" message:dealStatus delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert setTag:22];
        [alert release];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"TangoTab" message:dealStatus delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert setTag:33];
        [alert release];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==22) {
        if (buttonIndex==0) {
            sharedDelegate.isSelectedDisButton = YES;
            sharedDelegate.myOffersUpdate=NO;
            [[self tabBarController] setSelectedIndex:0];
        }
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

-(IBAction)mapButtonClicked:(id)sender
{    
  
    if (sharedDelegate.isNotReachable == YES) {
        [self stopActivityIndicatorView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionality will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
        @try {
            
            searchmapViewCtrl = [[SearchMapViewcontroller alloc] initWithNibName:@"SearchMapViewcontroller" bundle:[NSBundle mainBundle]];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:sharedDelegate.nearMeDetailDict];
            searchmapViewCtrl.placesMapArray = array;
            [array release];
            [self.navigationController pushViewController:searchmapViewCtrl animated:YES];
        }
        @catch (NSException *exception) {
        }
    }
}

- (void)dealloc {
    [sharedDelegate release];
    [myImageView release];
    [searchmapViewCtrl release];
    [restaurantNameLabel release];
    [restaurantLocationLabel release];
    [dealNameLabel release];
    [creditValueLabel release];
    [cuisineTypeIdLabel release];
    [dateAndTimeLabel release];
    [dealTimeButton release]; 
    [dealDescriptionLabel release];
    [dealRestriction release];
    [backBarButton release];
    [imageURL release];
    [networkQueue cancelAllOperations];
    [networkQueue release];
    [currentelement release];
    [dealStatus release];
    [activityIndicatorView release];
	[super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
