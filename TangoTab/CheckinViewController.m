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
@synthesize coordinates, lastCoordinates;
@synthesize networkQueue;
@synthesize failed,autoCheckStatus;
@synthesize activityIndicatorView;
@synthesize currentelement;
@synthesize checkinstatusmessage,backBarButton,CheckInButton,sharedDelegate,manuCheck, distanceFromDeal;
@synthesize gpsAccuracy, gpsCurrentLocation, gpsDistanceToDeal, gpsUpdateCounter;

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
    manuCheck= NO;
    gpsUpdateCount = 0;
    
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
    [dff setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStrig = [NSString stringWithFormat:@"%@",[dateArr objectAtIndex:0]];
    NSDate *date = [dff dateFromString:dateStrig];
    
    NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
    [dateformstring setDateFormat:@"EEE, MMM dd yyyy"];
    NSString *resultDate4 = [dateformstring stringFromDate:date];
    
    
	[timestamp_lable setText:[NSString stringWithFormat:@"%@ %@ to %@",resultDate4,[checkinDetails valueForKey:@"start_time"],[checkinDetails valueForKey:@"end_time"]]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"image_url"]];
	NSURL *url = [NSURL URLWithString:urlString];
	[asyncImageView loadImageFromURL:url];
    self.CheckInButton.hidden = YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.distanceFromDeal = 9999; // updated when GPS accuracy < 1 mile
    myofferLocation=[[MyOfferlocationController alloc]init];
    myofferLocation.delegate=self;
  //   if (sharedDelegate.isLocationUpdate == YES) {
 //       [CheckInButton setEnabled:NO];
 //   }
 //   if (sharedDelegate.isLocationUpdate == NO){
 //       [CheckInButton setEnabled:YES];
 //   }
}

-(void) viewDidDisappear:(BOOL)animated {
      [myofferLocation.myOfferlocationManager stopUpdatingLocation];
}

- (void) updateGpsStats:(CLLocation *)location {
    return;
    double accuracy = location.horizontalAccuracy;
    NSString *accuracyMsg = [NSString stringWithFormat:@"accuracy: %0.1f meters",accuracy];
    self.gpsAccuracy.text = accuracyMsg;
    NSString *positionMsg = [NSString stringWithFormat:@"pos: %0.4f, %0.4f",location.coordinate.latitude, location.coordinate.longitude];
   self.gpsCurrentLocation.text = positionMsg;
    
    float latitude = [[checkinDetails valueForKey:@"latitude"] floatValue];
    float longitude = [[checkinDetails valueForKey:@"longitude"] floatValue];
    float currlatitude =  location.coordinate.latitude;
    float currlongitude = location.coordinate.longitude;
    
    CLLocation *myOfferLocaion = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocation *currentLocaion = [[CLLocation alloc] initWithLatitude:currlatitude longitude:currlongitude];
    CLLocationDistance meters = [currentLocaion distanceFromLocation:myOfferLocaion];
    double milesToDeal = meters / 1608;
    NSString *distanceMsg = [NSString stringWithFormat:@"distance to deal: %0.2f miles",milesToDeal];
    self.gpsDistanceToDeal.text = distanceMsg;
    gpsUpdateCount = gpsUpdateCount + 1;
    NSString *updateMsg = [NSString stringWithFormat:@"gps update: %d ",gpsUpdateCount];
    self.gpsUpdateCounter.text = updateMsg;
    

}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)myOfferlocationUpdate:(CLLocation *)location
{
    
    
    float latitude = [[checkinDetails valueForKey:@"latitude"] floatValue];
    float longitude = [[checkinDetails valueForKey:@"longitude"] floatValue];
    float currlatitude =  location.coordinate.latitude;
    float currlongitude = location.coordinate.longitude;
    
    CLLocation *myOfferLocaion = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocation *currentLocaion = [[CLLocation alloc] initWithLatitude:currlatitude longitude:currlongitude];
    CLLocationDistance meters = [currentLocaion distanceFromLocation:myOfferLocaion];
    self.distanceFromDeal = meters;
  
    coordinates=[NSString stringWithFormat:@"%0.2f,%0.2f",currlatitude,currlongitude];
    
    if (self.lastCoordinates == nil)
        self.lastCoordinates = coordinates;
    
    if (meters <= 402)
        [myofferLocation.myOfferlocationManager stopUpdatingLocation];
    
    NSString *dateStrig = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"current_date"]];
    NSArray *datArray = [dateStrig componentsSeparatedByString:@" "];
    
    NSString *dateStrig2 = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"reserved_time_stamp"]];
    NSArray *datArray2 = [dateStrig2 componentsSeparatedByString:@" "];
    
    if ([[datArray objectAtIndex:0] isEqualToString:[datArray2 objectAtIndex:0]]) {
        if (meters <= 402 && checkinStatus == 0) {
            autoCheckStatus = YES;
       //     [CheckInButton setEnabled:NO];
            [self autocheckin:@"Y" autocheckDetail:nil userName:nil];
            checkinStatus = 1;
        }
    }
    
 /*   if (NSClassFromString(@"CLGeocoder")){
        
        myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [self reverseGeocodemethod:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, location.coordinate.latitude,location.coordinate.longitude]]; 
                [myofferLocation.myOfferlocationManager stopUpdatingLocation];
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
  */
}

- (void)myOfferlocationError:(NSError *)error
{
    [myofferLocation.myOfferlocationManager stopUpdatingLocation];
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
        
            CLLocation *myOfferLocaion = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude]; 
            CLLocation *currentLocaion = [[CLLocation alloc] initWithLatitude:currlatitude longitude:currlongitude];                      
            CLLocationDistance meters = [currentLocaion distanceFromLocation:myOfferLocaion];
            self.distanceFromDeal = meters;
            
            if (meters < 404.0) {
                autoCheckStatus = YES;
                [self autocheckin:@"Y" autocheckDetail:nil userName:nil];  
            
            }
        }
    }
    [coordinates copy];
}

- (void)showActivityIndicatorView: (NSString *)message {
	
	CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, cgSize.width, cgSize.height) label:message];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, cgSize.width, cgSize.height)];
		[self.view addSubview:activityIndicatorView];
	}
}


-(void) doManualCheckin {
    [self stopActivityIndicatorView];
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
        manuCheck=YES;
        [self autocheckin:@"N" autocheckDetail:nil userName:nil];
        
    }
    @catch (NSException *exception) {
        
    }

}

-(IBAction)checkin:(id)sender {
    // time check here
    
    NSString *offerStartTime = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"start_time"]];
    NSString *offerEndTime = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"end_time"]];
    NSString *offerDateStr = [NSString stringWithFormat:@"%@",[checkinDetails valueForKey:@"reserved_time_stamp"]];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    //test
 //   NSMutableDictionary *tdic = checkinDetails;
 //   [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    // too early
 //   currentDate = [df dateFromString: @"2012-12-06 10:44 AM"];
 //   offerStartTime = @"11:00 AM";
 //   offerEndTime = @"03:30 PM";
 //   offerDateStr = @"2012-12-06 05:00 PM";
    // within 15 minutes of start
  //  currentDate = [df dateFromString: @"2012-12-06 10:45 AM"];
    
    // too late future day
  //   currentDate = [df dateFromString: @"2012-12-07 10:44 AM"];
    
    // within 2 hours of offer ending
  //  currentDate = [df dateFromString: @"2012-12-06 05:29 PM"];
    
    // 2 hours after offer ending
  //  currentDate = [df dateFromString: @"2012-12-06 05:31 PM"];
    
    // offers ending at midnight
 //   offerStartTime = @"07:00 PM";
 //   offerEndTime = @"00:00 AM";
 //   offerDateStr = @"2012-12-06 07:00 PM";
 //   currentDate = [df dateFromString: @"2012-12-07 02:31 AM"];
    // end test
    
    NSArray *splitDate = [offerDateStr componentsSeparatedByString:@" "];

   
    [df setDateFormat:@"yyyy-MM-dd"];
  
    NSDate *offerDate = [df dateFromString: [splitDate objectAtIndex:0]];
    NSString *expiredDate = offerEndTime;
    if ([expiredDate isEqualToString:@"00:00 AM"])
        expiredDate = @"Midnight";
    NSString *validDate = offerStartTime;
    expiredDate = [expiredDate stringByAppendingString: @" on "];
    validDate = [validDate stringByAppendingString: @" on "];
    [df setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [df stringFromDate:offerDate];
    expiredDate = [expiredDate stringByAppendingString: dateString];
    validDate = [validDate stringByAppendingString: dateString];
    
    
    NSInteger interval = [[[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                          fromDate: currentDate
                                                            toDate: offerDate
                                                           options: 0] day];
    [df setDateFormat:@"hh:mm a"];
    NSDate *startTime = [df dateFromString: offerStartTime];
    NSDate *endTime = [df dateFromString: offerEndTime];
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:startTime];
	NSInteger startHour = [dateComponents hour];
    NSInteger startMiuntes = [dateComponents minute];

    dateComponents = [calendar components:unitFlags fromDate:endTime];
    NSInteger endHour = [dateComponents hour];
    NSInteger endMinutes = [dateComponents minute];

    dateComponents = [calendar components:unitFlags fromDate:currentDate];
    NSInteger currentHour = [dateComponents hour];
    NSInteger currentMinutes = [dateComponents minute];

    bool tooEarly = false;
    bool tooLate = false;
    bool tooLatePrompt = false;
    if (interval == -1) {
        // checking in after midnight for offer on previous day
        if (endHour == 0 && currentHour < 3)
        {
            tooLate = true;
            tooLatePrompt = true;
        }
        else
        if (endHour == 23 && currentHour < 2)
        {
            tooLate = true;
            tooLatePrompt = true;
        }
        else
        if (endHour == 22 && currentHour < 1)
        {
            tooLate = true;
            tooLatePrompt = true;
        }
        else
            tooLate = true;
        
    }
    else
    if(interval<0){
        tooLate = true;
    }else if (interval>0){
        tooEarly = true;
    }else{  // current day matches offer day
        
        if (currentHour < startHour)
        {
            if (currentHour + 1 == startHour)
            {
                if (startMiuntes > 0)
                    startMiuntes = startMiuntes - 15;
                else
                    startMiuntes = 45;
                if (currentMinutes < startMiuntes)
                    tooEarly = true;
            }
            else
                tooEarly = true;
        }
        
        if (tooEarly == false)
        {
            if ((currentHour - endHour) == 2)
            {
                if (currentMinutes - endMinutes > 0)
                {
                    tooLate = true;
                    tooLatePrompt = true;
                }
            }
            else
            if ((currentHour - endHour) > 2)
            {
                tooLate = true;
                tooLatePrompt = true;
            }
        }
    }
    
    if (tooEarly)
    {
        NSString *message = @"This offer is not valid until ";
        message = [message stringByAppendingString: validDate];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message: message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    else
    if (tooLate)
    {
        if (tooLatePrompt == false)
        {
            NSString *message = @"This offer expired at ";
            message = [message stringByAppendingString: expiredDate];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rats" message: message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            return;
        }
        else
        {
            NSString *message = @"Rats - This offer expired at ";
            message = [message stringByAppendingString: expiredDate];
             message = [message stringByAppendingString: @" Did you make it in time?"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
            [alertView show];
            [alertView release];
            return;
        }
    }
    
    // TEST
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pass" message: @"checkin would continue" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
 //   [alertView show];
 //   [alertView release];
 //   return;

    NSError *error = nil;
    // we don't have less than 1 mile accuracy
    if (self.distanceFromDeal == 9999)
    {
        [self showActivityIndicatorView: @"Determining Location..."];
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(doManualCheckin)
                                       userInfo:nil
                                        repeats:NO];
    }
    else
    if (self.distanceFromDeal < 1609.0)
    {
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
            manuCheck=YES;
            [self autocheckin:@"N" autocheckDetail:nil userName:nil];
           
        }
        @catch (NSException *exception) {
        
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Oops - your GPS does not show you're at the restaurant." delegate:self cancelButtonTitle:@"   I'm really here   " otherButtonTitles:@"I'm not there yet",nil];
        [alertView show];
        [alertView release];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    
    if ([alertView.title isEqualToString: @"Alert"])
    {
        if (buttonIndex == 0)
        {
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
                manuCheck=YES;
                [self autocheckin:@"N" autocheckDetail:nil userName:nil];
                
            }
            @catch (NSException *exception) {
                
            }

        }
        
    }
}

- (void) autocheckin:(NSString*)autoStatus autocheckDetail:(NSDictionary*)temDict userName:(NSString *)name
{
    NSString *serviceURL;
    if (self.lastCoordinates == nil)
        self.lastCoordinates = @"0.0,0.0";
    sharedDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (temDict) {
        serviceURL  = [NSString stringWithFormat:@"%@/mydeals/checkin?consumerresId=%@&name=%@&restname=%@&dealname=%@&dealdetails=%@&coordinate=%@&restEmailId=%@&autocheckin=%@",sharedDelegate.activeServerUrl,[temDict valueForKey:@"con_res_id"],name,[temDict valueForKey:@"business_name"],[temDict valueForKey:@"deal_name"],[temDict valueForKey:@"deal_description"],self.lastCoordinates,[temDict valueForKey:@"deal_manager_emailid"],autoStatus];
    }
    else {
        
        serviceURL  = [NSString stringWithFormat:@"%@/mydeals/checkin?consumerresId=%@&name=%@ %@&restname=%@&dealname=%@&dealdetails=%@&coordinate=%@&restEmailId=%@&autocheckin=%@",sharedDelegate.activeServerUrl,[checkinDetails valueForKey:@"con_res_id"],[sharedDelegate.searchingradies objectForKey:@"firstname"],[sharedDelegate.searchingradies objectForKey:@"last_name"],[checkinDetails valueForKey:@"business_name"],[checkinDetails valueForKey:@"deal_name"],[checkinDetails valueForKey:@"deal_description"],self.lastCoordinates,[checkinDetails valueForKey:@"deal_manager_emailid"],autoStatus];
    }
    
    NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
    [self sendASIHTTPRequest:url];
}

-( void) sendASIHTTPRequest:(NSURL*)serverURLs
{
    
 //   if (networkQueue) {
//		[networkQueue cancelAllOperations];
 //       [networkQueue setDelegate:nil];
//	}
	failed = NO;
//	[networkQueue reset];
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
        if ( manuCheck==NO && [checkinstatusmessage isEqualToString:@"Successfully CheckIn."]) {
       //     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check In" message:@"You have successfully checked in." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
       //     [alertView show];
       //     [alertView release];
            sharedDelegate.myOffersUpdate=NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            if (autoCheckStatus) {
                if ([checkinstatusmessage isEqualToString:@"You have already checked in here."] || [checkinstatusmessage isEqualToString:@"You cannot check into this offer.  it has already expired or not valid yet"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:checkinstatusmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    
                }
                else {
                    NSArray *convString = [checkinstatusmessage componentsSeparatedByString:@"."];
                    NSString *strr = [NSString stringWithFormat:@"%@.",[convString objectAtIndex:0]];
                    NSString *bodystrr = [NSString stringWithFormat:@"%@.",[convString objectAtIndex:1]];

                    if ([checkinstatusmessage isEqualToString:@"Successfully CheckIn."]) {
                        bodystrr = @"Successfully Checked In";
                    }
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strr message:bodystrr delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    // rebuild local notifications
                    sharedDelegate.myOffersUpdate=NO;
                    [self.navigationController popViewControllerAnimated:YES];
                }
                autoCheckStatus = NO;
            }
            else {
                if (manuCheck==YES){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:checkinstatusmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    manuCheck=NO;
                    // rebuild local notifications
                    sharedDelegate.myOffersUpdate=NO;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
  //  [CheckInButton setEnabled:YES];
}

- (void)showActivityIndicatorView {
	CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, cgSize.width, cgSize.height)];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, cgSize.width, cgSize.height)];
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
