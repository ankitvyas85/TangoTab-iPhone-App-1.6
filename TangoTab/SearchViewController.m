//
//  SearchViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "SearchViewController.h"
#import "JSON.h"

@implementation SearchViewController

@synthesize searchLocation,sharedDelegate,nearmeDetailVCtrl,searchDetailview;
@synthesize searchTableView,restaurantSearchBar,addressSearchBar;
@synthesize searchArray,latandlng,reverseGeoCoder,myGeocoder,currentElement,dealid,serverURL,imagesArray,currentAddressDict;
@synthesize showMore,networkQueue,mapViewCtrl,pageIndex,noOfOffers,failed,searchDetails;

@synthesize noOfdeals,dealsfrom,cuisine_type_id,business_name,deal_name,image_url,rest_deal_restrictions,deal_description,driving_distance,rest_deal_availablestart_date,rest_deal_start_date,rest_deal_end_date,available_start_time,available_end_time,available_week_days,deal_credit_value,location_rest_address,address,no_deals_available;
@synthesize nodata_Lable, urlDealDate, urlDealId, fakeClick, clickOccured;


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
    searchArray = [[NSMutableArray alloc] init];
    serverURL = [[NSString alloc] init];
    imagesArray = [[NSMutableArray alloc] init];
    failed = NO;
    pageIndex = 2;
    sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    nodata_Lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 150, 320, 50)];
    [nodata_Lable setNumberOfLines:2];
    [nodata_Lable setAlpha:0.5];
    self.fakeClick = NO;
    self.clickOccured = NO;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.urlDealId = @"";
    self.navigationController.navigationBarHidden=YES;
    searchLocation = [[SearchLocation alloc] init];
    searchLocation.delegate =self;
   
    if ([searchArray count]<10){
        searchTableView.tableFooterView.hidden=YES;
    }
    if (sharedDelegate.updateSearch==YES) {
        if ([searchArray count]!=0) {
            [searchArray removeAllObjects];
            [restaurantSearchBar setText:@""];
            [addressSearchBar setText:@""];
            [searchTableView reloadData];
            sharedDelegate.updateSearch=NO;
        }
    }
    if ([sharedDelegate.urlAction isEqualToString:@"search"])
    {
        NSString *searchCity = [sharedDelegate.urlActionParameters valueForKey:@"city"];
        [self.addressSearchBar setText:searchCity];
        if ([searchArray count] >0) {
            [searchArray removeAllObjects];
            searchTableView.tableFooterView.hidden = YES;
            [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        [self getValuesFromServer];          
    }
    else
    if ([sharedDelegate.urlAction isEqualToString:@"deal"])
    {
        if ([searchArray count] >0) {
            [searchArray removeAllObjects];
            searchTableView.tableFooterView.hidden = YES;
            [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        [self.addressSearchBar setText: @""];
        self.urlDealId = [sharedDelegate.urlActionParameters valueForKey:@"dealId"];
        self.urlDealDate = [sharedDelegate.urlActionParameters valueForKey:@"date"];
        self.clickOccured = [sharedDelegate.urlActionParameters valueForKey:@"clickOccured"];
        if ([self.clickOccured isEqualToString:@"NO"])
            self.fakeClick = YES;
        [self getValuesFromServer];
         
    }
    self.navigationBar.topItem.title = [sharedDelegate currentServer:@"Search"];

}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)locationUpdate:(CLLocation *)location
{
    if (NSClassFromString(@"CLGeocoder")){
        
        myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count]>0){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [self reverseGeo:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, location.    coordinate.latitude,location.coordinate.longitude]];                
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

- (void) locationError :(NSError *)error
{
    NSLog(@"%@",error);
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark 
{
    @try {
        [self reverseGeo:[NSString stringWithFormat:@"%@,%@,%@;%@;%f,%f",placemark.locality, placemark.administrativeArea,placemark.country, placemark.postalCode, placemark.coordinate.latitude, placemark.coordinate.longitude]];
        [reverseGeoCoder cancel];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    sharedDelegate.isLocationUpdate = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"Your device is configured to deny Location Services to TangoTab. Some features of TangoTab require these services to work. Please enable Location Services in the Settings App to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)reverseGeo:(NSString *)addressString{
    
    NSDictionary *d = [NSDictionary dictionaryWithObject:addressString forKey:@"location"];
    
    currentAddressDict = [[NSMutableDictionary alloc] initWithDictionary:d];
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    pageIndex = 2;
    sharedDelegate.urlAction = @"";
    sharedDelegate.urlActionController = @"";
    self.urlDealId = @"";
	@try {
        if ([searchArray count] >0) {
            [searchArray removeAllObjects];
            searchTableView.tableFooterView.hidden = YES;
            [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        [restaurantSearchBar resignFirstResponder];
        [addressSearchBar resignFirstResponder];
        NSError *error;
        if (theSearchBar.tag == 1) {
            if (![[GANTracker sharedTracker] trackEvent:@"Search Restaurant"
                                                 action:@"TrackEvent"
                                                  label:[theSearchBar text]
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Search Restaurant",
                                        @"Search Button",
                                        nil];
            [FlurryAnalytics logEvent:@"Search" withParameters:dictionary];

        } else if (theSearchBar.tag == 2) {
            if (![[GANTracker sharedTracker] trackEvent:@"Search City, State or Zip Code"
                                                 action:@"TrackEvent"
                                                  label:[theSearchBar text]
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Search City, State or Zip Code",
                                        @"Search Button",
                                        nil];
            [FlurryAnalytics logEvent:@"Search" withParameters:dictionary];
            
        }                
        [self getValuesFromServer];
    }
    @catch (NSException *exception) {
        
    }

}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
	if (searchBar.tag == 1) {
		if ([restaurantSearchBar.text length] == 0) {
			[restaurantSearchBar resignFirstResponder];
		}
	}
	else if (searchBar.tag == 2){
		if ([addressSearchBar.text length] == 0) {
			[addressSearchBar resignFirstResponder];
		}
	}	
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	if (searchBar.tag == 1) {
		if (([restaurantSearchBar.text length] == 0)) {

		}
        restaurantSearchBar.showsCancelButton = YES;
	}
	else if(searchBar.tag == 2){
		if (([addressSearchBar.text length] == 0)) {
		}
        addressSearchBar.showsCancelButton = YES;
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    if (searchBar.tag == 1) {
        restaurantSearchBar.showsCancelButton = NO;
    }
    else if (searchBar.tag == 2) {
        
        addressSearchBar.showsCancelButton = NO;
    }    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	
	[restaurantSearchBar resignFirstResponder];
    [addressSearchBar resignFirstResponder];
}





-(void) getValuesFromLocation {
   
    @try {
        
        NSString *stringAddress = [NSString stringWithFormat:@"%@",addressSearchBar.text]; 
        
       /* NSString *urlst = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/geo?q=%@&output=csv&sensor=true", [stringAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];*/
		
		
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
		latandlng =[[NSString alloc] initWithFormat:@"%@,%@",[dV valueForKey:@"lat"],[dV valueForKey:@"lng"]];
        [parser release];
	        
    }
    @catch (NSException *exception) {
        
    }
}

-(void) getValuesFromServer {
    
    if (![self.urlDealId isEqualToString:@""])
    {
        
        serverURL = [NSString stringWithFormat:@"%@/deals/get?dealId=%@&date=%@&coordinate=%@",sharedDelegate.activeServerUrl,self.urlDealId,self.urlDealDate, [sharedDelegate currentLatLon]];
        NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        debug_NSLog(@"WS-> %@",[searchurl absoluteString]);
        [self sendASIHTTPRequest:searchurl];
    }
    else {
    [self getValuesFromLocation];
    
    if ([currentAddressDict count] !=0) {
        
        NSString *currAddString = [currentAddressDict valueForKey:@"location"];
        
        NSArray *addArray = [currAddString componentsSeparatedByString:@";"];
        
        if ([addressSearchBar.text length] == 0 ) {
            
            serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=0&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,[sharedDelegate.searchingradies objectForKey:@"radies"],[addArray objectAtIndex:2],[sharedDelegate.userdetails  valueForKey:@"userId"]];
            
            NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [self sendASIHTTPRequest:searchurl];
            
        }   
        else {
            serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=0&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,[sharedDelegate.searchingradies objectForKey:@"radies"],latandlng,[sharedDelegate.userdetails  valueForKey:@"userId"]];
            
            NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [self sendASIHTTPRequest:searchurl];
            
        }        
    }
    else {
        if ([addressSearchBar.text length]==0 ) {
            serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=0&noOfdeals=0&searchingradius=%@&coordinate=&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,[sharedDelegate.searchingradies objectForKey:@"radies"],[sharedDelegate.userdetails  valueForKey:@"userId"]];
            
            NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [self sendASIHTTPRequest:searchurl];
        }
        else {
            serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=0&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,[sharedDelegate.searchingradies objectForKey:@"radies"],latandlng,[sharedDelegate.userdetails valueForKey:@"userId"]];
            
            NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [self sendASIHTTPRequest:searchurl];
        }
    }
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
    
}
        
- (void)FetchComplete:(ASIHTTPRequest *)request 
{
    NSString *respose = [request responseString];
    debug_NSLog(@"WS-> %@",respose);

    [self parseXML:respose];
}

- (void)FetchFailed:(ASIHTTPRequest *)request
{
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
    currentElement=[[NSMutableString alloc]init];
    currentElement=[elementName copy];
    if ([elementName isEqualToString:@"deal"]) {
        int idValue = [[attributeDict objectForKey:@"id"] intValue];
        dealid=[[NSString alloc] initWithFormat:@"%i",idValue];
        NSMutableArray *temp=[[NSMutableArray alloc]init];
        [temp addObject:[attributeDict valueForKey:@"id"]];
        searchDetails    = [[NSMutableDictionary alloc]init];
        noOfdeals        = [[NSMutableString alloc] init];
        dealsfrom        = [[NSMutableString alloc] init];
        business_name    = [[NSMutableString alloc]init];
        cuisine_type_id  = [[NSMutableString alloc]init];
        deal_name        = [[NSMutableString alloc]init];
        rest_deal_restrictions  = [[NSMutableString alloc]init];
        driving_distance       = [[NSMutableString alloc]init];
        rest_deal_availablestart_date =[[NSMutableString alloc]init];
        rest_deal_start_date   = [[NSMutableString alloc]init];
        rest_deal_end_date     = [[NSMutableString alloc]init];
        available_start_time   = [[NSMutableString alloc]init];
        available_end_time     = [[NSMutableString alloc]init];
        available_week_days    = [[NSMutableString alloc]init];
        deal_description       = [[NSMutableString alloc]init];
        deal_credit_value      = [[NSMutableString alloc]init];
        location_rest_address  = [[NSMutableString alloc]init];
        address                = [[NSMutableString alloc]init];
        no_deals_available     = [[NSMutableString alloc]init];
        image_url              = [[NSMutableString alloc]init];        
    }
    
}
        
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([currentElement isEqualToString:@"noOfdeals"]) {
        [noOfdeals appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"dealsfrom"]) {
        [dealsfrom appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"business_name"]) {
        [business_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"cuisine_type_id"]) {
        [cuisine_type_id appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"deal_name"]) {
        [deal_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"rest_deal_restrictions"]) {
        [rest_deal_restrictions appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"driving_distance"]) {
        [driving_distance appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"rest_deal_availablestart_date"]) {
        [rest_deal_availablestart_date appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"rest_deal_start_date"]) {
        [rest_deal_start_date appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"rest_deal_end_date"]) {
        [rest_deal_end_date appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"available_start_time"]) {
        [available_start_time appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"available_end_time"]) {
        [available_end_time  appendString:terstring];
    }  
    else if ([currentElement isEqualToString:@"available_week_days"]) {
        [available_week_days appendString:terstring];
    }  
    else if ([currentElement isEqualToString:@"deal_description"]) {
        [deal_description appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"deal_credit_value"]) {
        [deal_credit_value appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"address"]) {
        [address appendString:terstring];
        terstring = [terstring stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [location_rest_address appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"address"]) {
        [address appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"no_deals_available"]) {
        [no_deals_available appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"image_url"]) {
        [image_url appendString:terstring];
    }
}
        
        
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    if ([elementName isEqualToString:@"deal"]) {
        [searchDetails setValue:dealid forKey:@"id"];
        [searchDetails setValue:noOfdeals forKey:@"noOfdeals"];
        [searchDetails setValue:dealsfrom forKey:@"dealsfrom"];
        [searchDetails setValue:business_name forKey:@"business_name"];
        [searchDetails setValue:cuisine_type_id forKey:@"cuisine_type_id"];
        [searchDetails setValue:deal_name forKey:@"deal_name"];
        [searchDetails setValue:rest_deal_restrictions forKey:@"rest_deal_restrictions"];
        [searchDetails setValue:driving_distance forKey:@"driving_distance"];
        [searchDetails setValue:rest_deal_availablestart_date forKey:@"rest_deal_availablestart_date"];
        [searchDetails setValue:rest_deal_start_date forKey:@"rest_deal_start_date"];
        [searchDetails setValue:rest_deal_end_date forKey:@"rest_deal_end_date"];
        [searchDetails setValue:available_start_time  forKey:@"available_start_time"];
        [searchDetails setValue:available_end_time forKey:@"available_end_time"];
        [searchDetails setValue:available_week_days forKey:@"available_week_days"];
        [searchDetails setValue:deal_description forKey:@"deal_description"];
        [searchDetails setValue:deal_credit_value forKey:@"deal_credit_value"];
        [searchDetails setValue:location_rest_address forKey:@"location_rest_address"];
        [searchDetails setValue:address forKey:@"address"];
        [searchDetails setValue:no_deals_available forKey:@"no_deals_available"];
        [searchDetails setValue:image_url forKey:@"image_url"];
        [searchArray addObject:searchDetails];
        
    }
}
        
-(void)parserDidEndDocument:(NSXMLParser *)parser{
   
    for (int i=0; i<[searchArray count]; i++) {
        UIImage *img=[UIImage imageNamed:@"person.gif"];
        NSData *data=[NSData dataWithData:UIImagePNGRepresentation(img)];
        [imagesArray addObject:data];
    }
    
    if ([searchArray count]!=0) {
        [nodata_Lable removeFromSuperview];
        [searchTableView reloadData];
        if (self.fakeClick == YES)
        {
            self.fakeClick = NO;
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(simClick:)
                                           userInfo:nil
                                            repeats:NO];
            
           
        }
    }
    else{
        [nodata_Lable setText:@"Sorry, No offers match the search criteria."];
        [self.view addSubview:nodata_Lable];
        searchTableView.tableFooterView.hidden = YES;
        [searchTableView reloadData];
    }
}

- (void) simClick:(NSTimer *)timer {
    [sharedDelegate.urlActionParameters setObject:@"YES" forKey:@"clickOccured"];
    [self tableView:self.searchTableView didSelectRowAtIndexPath:0];
}
        
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [searchArray count];
}

        
#define ASYNC_IMAGE_TAG 999
        
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AsyncImageView *asyncImageView = nil;
    
    SearchCustomCell *cell = (SearchCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        NSArray *myCells = [[NSBundle mainBundle] loadNibNamed:@"SearchCustomCell" owner:self options:nil];
        for(id oneObject in myCells)
        {
            if([oneObject isKindOfClass:[SearchCustomCell class]])
            {
                cell = (SearchCustomCell*) oneObject;
            }
        }
	}
	else {
		asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
	}
    
    noOfOffers=[[[searchArray objectAtIndex:0]objectForKey:@"noOfdeals"]integerValue];
    if (noOfOffers>10) {
        showMore=[UIButton buttonWithType:UIButtonTypeCustom];
        [showMore setFrame:CGRectMake(0, 210, 320, 40)];
        [showMore setImage:[UIImage imageNamed:@"dark_showmore_btn.png"] forState:UIControlStateNormal];
        [showMore addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        searchTableView.tableFooterView=showMore;
    }
    if([searchArray count]==noOfOffers){
        searchTableView.tableFooterView.hidden=YES;
    }
    
    if ([searchArray count] >0) {
        
        NSDictionary *detailsEntries = [searchArray objectAtIndex:indexPath.row];
        [cell.restaurantNameLabel setText:[detailsEntries valueForKey:@"business_name"]];
        [cell.dealNameLabel setText:[detailsEntries valueForKey:@"deal_name"]];
        
        
        if (sharedDelegate.isLocationUpdate == YES && [restaurantSearchBar.text length] > 0 && [addressSearchBar.text length] == 0) {
            [cell.distanceLabel setText:nil];  
        }
        else {
            [cell.distanceLabel setText:[NSString stringWithFormat:@"%.1f miles", [[detailsEntries valueForKey:@"driving_distance"] doubleValue]]];
        }
        
        [cell.dealsAvailableLabel setText:[NSString stringWithFormat:@"%@ offers available",[detailsEntries valueForKey:@"no_deals_available"]]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateStrig = [NSString stringWithFormat:@"%@",[detailsEntries valueForKey:@"rest_deal_availablestart_date"]];
        
        NSDate *date = [dateFormatter dateFromString:dateStrig];
        
        NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
        [dateformstring setDateFormat:@"MM-dd-yyyy"];
        
        NSString *resultDate = [NSString stringWithFormat:@"%@, %@ to %@",[dateformstring stringFromDate:date],[detailsEntries valueForKey:@"available_start_time"],[detailsEntries valueForKey:@"available_end_time"] ];
        
        [cell.timeStampLabel setText:resultDate];
        
        NSString *urlString = [NSString stringWithFormat:@"%@",[detailsEntries objectForKey:@"image_url"]];
        NSString *terurlString = [[urlString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        NSURL *url = [NSURL URLWithString:terurlString];
        
        [cell.asyncImageView loadImageFromURL:url];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
//	return 120;
    return 93;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    searchDetailview = [[SearchDetailViewController alloc] initWithNibName:@"SearchDetailViewController" bundle:[NSBundle mainBundle]];
    
    sharedDelegate.nearMeDetailDict = [searchArray objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:searchDetailview animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(void)showMoreAction:(id)sender {
    
    UIButton *btn1=(id)sender;
    btn1.userInteractionEnabled=NO;
    @try {
        if ([searchArray count]!=noOfOffers) {
            
            if ([currentAddressDict count] !=0) {
                
                NSString *currAddString = [currentAddressDict valueForKey:@"location"];
                
                NSArray *addArray = [currAddString componentsSeparatedByString:@";"];
                
                if ([restaurantSearchBar.text length] != 0   && [addressSearchBar.text length] == 0) {
                    
                    serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=%i&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,pageIndex,[sharedDelegate.searchingradies objectForKey:@"radies"],[addArray objectAtIndex:2],[sharedDelegate.userdetails  valueForKey:@"userId"]];
                    
                    NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    
                    NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    [self sendASIHTTPRequest:searchurl];
                    
                }   
                else {
                    serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=%i&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,pageIndex,[sharedDelegate.searchingradies objectForKey:@"radies"],latandlng,[sharedDelegate.userdetails  valueForKey:@"userId"]];
                    
                    NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    
                    NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    [self sendASIHTTPRequest:searchurl];
                    
                }
            }
            else {
                if ([addressSearchBar.text length]==0 ) {
                    
                    serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=%i&noOfdeals=0&searchingradius=%@&coordinate=&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,pageIndex,[sharedDelegate.searchingradies objectForKey:@"radies"],[sharedDelegate.userdetails  valueForKey:@"userId"]];
                    
                    NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    
                    NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    [self sendASIHTTPRequest:searchurl];
                }
                else {
                    serverURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@&pageIndex=%i&noOfdeals=0&searchingradius=%@&coordinate=%@&userId=%@",sharedDelegate.activeServerUrl,restaurantSearchBar.text,addressSearchBar.text,pageIndex,[sharedDelegate.searchingradies objectForKey:@"radies"],latandlng,[sharedDelegate.userdetails  valueForKey:@"userId"]];
                    
                    NSString *terserviceURL = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    
                    NSURL *searchurl = [NSURL URLWithString:[terserviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    [self sendASIHTTPRequest:searchurl];
                }
            }
          pageIndex++;  
        }
        else{
            searchTableView.tableFooterView.hidden=YES;
        }
    
    }
    @catch (NSException *exception) {
        
    }
}

-(void)dealloc {
    
    [searchTableView release];
    [restaurantSearchBar release];
    [addressSearchBar release];
    [showMore release];
    [searchArray release ];
    [imagesArray release];
    [searchDetails release];
    [currentAddressDict release];
    [noOfdeals release];
    [dealsfrom release];
    [cuisine_type_id release];[driving_distance release];[business_name release];[deal_name release];[image_url release];[rest_deal_restrictions release];[deal_description release];[rest_deal_availablestart_date release];[rest_deal_start_date release];[rest_deal_end_date  release];[available_start_time  release];[available_end_time  release];[available_week_days release];[deal_credit_value  release];[location_rest_address  release];[address release];[no_deals_available release];
    [nodata_Lable  release];
    [latandlng release];[currentElement release];[dealid release];[serverURL release];
    [reverseGeoCoder release];
    [myGeocoder  release];
    [searchLocation  release];
    [networkQueue cancelAllOperations];
    [networkQueue  release];
    [mapViewCtrl  release];
    [sharedDelegate  release];
    [nearmeDetailVCtrl  release];
    

}



@end
