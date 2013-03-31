//
//  NearMeViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearMeViewController.h"


@implementation NearMeViewController
@synthesize nearTableView;
@synthesize serverURL;
@synthesize allEntries,addressArray;
@synthesize details;
@synthesize currentElement,dealid;
@synthesize noOfdeals,dealsfrom,cuisine_type_id,business_name,deal_name,image_url,rest_deal_restrictions,deal_description,driving_distance,rest_deal_availablestart_date,rest_deal_start_date,rest_deal_end_date,available_start_time,available_end_time,available_week_days,deal_credit_value,location_rest_address,address,no_deals_available;
@synthesize imagesArray;
@synthesize myLocation,reverseGeoCoder,myGeocoder;
@synthesize activityIndicatorView;
@synthesize nearmeDetailVCtrl;
@synthesize networkQueue;
@synthesize failed;
@synthesize sharedDelegate;
@synthesize mapViewCtrl;
@synthesize pageIndex,noOfOffers,showMore;
@synthesize nodata_Lable,mapBarButton;



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
}

#pragma mark - View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];  

    pageIndex=2;
    sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    allEntries = [[NSMutableArray alloc] init];
    imagesArray = [[NSMutableArray alloc] init];
    serverURL = [[NSString alloc] init];
    if (sharedDelegate.isSelectedDisButton == NO) {
        myLocation = [[MyCLLocation alloc] init];
        myLocation.delegate = self;
    }
    nodata_Lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, 320, 80)];
    [nodata_Lable setNumberOfLines:5];
    [nodata_Lable setAlpha:0.5];
   
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;
    [super viewWillAppear:YES];
    
    if ([allEntries count]<10) {
        nearTableView.tableFooterView.hidden=YES;
    }
    if (sharedDelegate.isSelectedDisButton == YES) {
        pageIndex=2;
        [nodata_Lable removeFromSuperview];
        nearTableView.tableFooterView.hidden=YES;
        myLocation = [[MyCLLocation alloc] init];
        myLocation.delegate = self;
        sharedDelegate.isSelectedDisButton = NO;
    }
}



- (void)locationUpdate:(CLLocation *)location
{
    sharedDelegate.isLocationUpdate = NO;
    if (NSClassFromString(@"CLGeocoder")){
        myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0){
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

- (void)locationError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        sharedDelegate.isLocationUpdate = YES;
        [mapBarButton setEnabled:NO];
        UITabBarItem *tabBarItem = [[self.tabBarController.tabBar items] objectAtIndex:1];
        [tabBarItem setEnabled:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"Your device is configured to deny Location Services to TangoTab. Some features of TangoTab require these services to work. Please enable Location Services in the Settings App to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

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
    if ([error code] == kCLErrorDenied) {
        sharedDelegate.isLocationUpdate = YES;
        [mapBarButton setEnabled:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"Your device is configured to deny Location Services to TangoTab. Some features of TangoTab require these services to work. Please enable Location Services in the Settings App to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}


#pragma GCC diagnostic warning "-Wdeprecated-declarations"
-(void)reverseGeo:(NSString *)addressString{
    
    NSDictionary *d = [NSDictionary dictionaryWithObject:addressString forKey:@"location"];

    [self refresh:d];
}


- (void)refresh:(NSDictionary *)addressDict {
    
    if ([allEntries count] > 0) {
        [allEntries removeAllObjects];
    }
    [nearTableView reloadData];
    
    NSString *zipCode = [addressDict valueForKey:@"location"];
    
    NSString *terZipCode = [zipCode stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSArray *arr = [terZipCode componentsSeparatedByString:@";"];
    
    addressArray = [[NSArray alloc] initWithArray:arr];
    NSString *verString = [NSString stringWithFormat:@"%.1@",sharedDelegate.versionString];
    serverURL = [[NSString alloc]initWithFormat:@"%@/deals/search?type=A&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@&pageIndex=0&noOfdeals=0&restName=&address=&version=%@&userId=%@",SERVER_URL,[arr objectAtIndex:0],[arr objectAtIndex:1],[arr objectAtIndex:2],[sharedDelegate.searchingradies objectForKey:@"radies"],verString,[sharedDelegate.userdetails  valueForKey:@"userId"]];
    
    NSString *terString = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendASIHTTPRequest:url];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        sharedDelegate.isSelectedDisButton = YES;
        failed = YES;
    }
}

-(IBAction)mapButtonClicked:(id)sender {
    
     mapViewCtrl =[[Mapviewcontroller alloc]initWithNibName:@"Mapviewcontroller" bundle:[NSBundle mainBundle]];
    sharedDelegate.nearmedidSele = YES;
    if ([allEntries count]!=0) {
        mapViewCtrl.placesMapArray = allEntries;
        [mapViewCtrl.currentArray arrayByAddingObjectsFromArray:addressArray];
        [self.navigationController pushViewController:mapViewCtrl animated:YES];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        details          = [[NSMutableDictionary alloc]init];
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
   else if ([currentElement isEqualToString:@"location_rest_address"]) {
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
        [details setValue:dealid forKey:@"id"];
        [details setValue:noOfdeals forKey:@"noOfdeals"];
        [details setValue:dealsfrom forKey:@"dealsfrom"];
        [details setValue:business_name forKey:@"business_name"];
        [details setValue:cuisine_type_id forKey:@"cuisine_type_id"];
        [details setValue:deal_name forKey:@"deal_name"];
        [details setValue:rest_deal_restrictions forKey:@"rest_deal_restrictions"];
        [details setValue:driving_distance forKey:@"driving_distance"];
        [details setValue:rest_deal_availablestart_date forKey:@"rest_deal_availablestart_date"];
        [details setValue:rest_deal_start_date forKey:@"rest_deal_start_date"];
        [details setValue:rest_deal_end_date forKey:@"rest_deal_end_date"];
        [details setValue:available_start_time  forKey:@"available_start_time"];
        [details setValue:available_end_time forKey:@"available_end_time"];
        [details setValue:available_week_days forKey:@"available_week_days"];
        [details setValue:deal_description forKey:@"deal_description"];
        [details setValue:deal_credit_value forKey:@"deal_credit_value"];
        [details setValue:location_rest_address forKey:@"location_rest_address"];
        [details setValue:address forKey:@"address"];
        [details setValue:no_deals_available forKey:@"no_deals_available"];
        [details setValue:image_url forKey:@"image_url"];
        [allEntries addObject:details];
    }
    NSLog(@"NearMe:%@",allEntries);
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];

    for (int i=0; i<[allEntries count]; i++) {
        UIImage *img=[UIImage imageNamed:@"person.gif"];
        NSData *data=[NSData dataWithData:UIImagePNGRepresentation(img)];
        [imagesArray addObject:data];
    }
    
    if ([allEntries count]!=0) {
        [mapBarButton setEnabled:YES];
        [nodata_Lable removeFromSuperview];
        [nearTableView reloadData];
    }
    else{
        [nodata_Lable setText:@"Sorry, there are no offers around your current location. Please broaden your search criteria using the search button on the bottom of this screen."];
        [self.view addSubview:nodata_Lable];
        nearTableView.tableFooterView.hidden=YES;
        [mapBarButton setEnabled:NO];
    }

}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
   
    return [allEntries count];
}


#define ASYNC_IMAGE_TAG 999

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    NearMeCustomCell *cell = (NearMeCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        NSArray *myCells = [[NSBundle mainBundle] loadNibNamed:@"NearMeCustomCell" owner:self options:nil];
        for(id oneObject in myCells)
        {
            if([oneObject isKindOfClass:[NearMeCustomCell class]])
            {
                cell = (NearMeCustomCell*) oneObject;
            }
        }
	}
  
    noOfOffers=[[[allEntries objectAtIndex:0]objectForKey:@"noOfdeals"]integerValue];
    if (noOfOffers>10) {
        showMore=[UIButton buttonWithType:UIButtonTypeCustom];
        [showMore setFrame:CGRectMake(0, 210, 320, 40)];
        [showMore setImage:[UIImage imageNamed:@"dark_showmore_btn.png"] forState:UIControlStateNormal];
        [showMore addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        nearTableView.tableFooterView=showMore;
    }
     if([allEntries count]==noOfOffers){
        nearTableView.tableFooterView.hidden=YES;
    }
    if ([allEntries count] >0) {
       
        NSDictionary *detailsEntries = [allEntries objectAtIndex:indexPath.row];
        [cell.restaurantNameLabel setText:[detailsEntries valueForKey:@"business_name"]];
        [cell.dealNameLabel setText:[detailsEntries valueForKey:@"deal_name"] ];
        //[cell.restaurantType setText:[detailsEntries valueForKey:@"cuisine_type"]];
        [cell.drivingDistanceLabel setText:[NSString stringWithFormat:@"%.1f miles", [[detailsEntries valueForKey:@"driving_distance"] doubleValue]]];
        
        [cell.dealsAvailableLabel setText:[NSString stringWithFormat:@"%@ offers available",[detailsEntries valueForKey:@"no_deals_available"]]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        
        NSString *dateStrig = [NSString stringWithFormat:@"%@",[detailsEntries valueForKey:@"rest_deal_availablestart_date"]];
        
        NSDate *date = [dateFormatter dateFromString:dateStrig];
        
        NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
        [dateformstring setDateFormat:@"MM-dd-YYYY"];
        
        NSString *resultDate = [NSString stringWithFormat:@"%@, %@ to %@",[dateformstring stringFromDate:date],[detailsEntries valueForKey:@"available_start_time"],[detailsEntries valueForKey:@"available_end_time"]];
        
        
        
        [cell.timeStampLabel setText:resultDate];
        
        NSString *urlString = [NSString stringWithFormat:@"%@",[detailsEntries objectForKey:@"image_url"]];
        NSString *terurlString = [[urlString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        NSURL *url = [NSURL URLWithString:terurlString];
        
        [cell.asyncimageview loadImageFromURL:url];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	return 124;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    nearmeDetailVCtrl = [[NearMeDetailViewController alloc] initWithNibName:@"NearMeDetailViewController" bundle:[NSBundle mainBundle]];
    
    sharedDelegate.nearMeDetailDict = [allEntries objectAtIndex:indexPath.row];
    sharedDelegate.nearmedidSele = YES;
    [self.navigationController pushViewController:nearmeDetailVCtrl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)showMoreAction:(id)sender {
    UIButton *btn1=(id)sender;
    btn1.userInteractionEnabled=NO;
    @try {
        if ([allEntries count]!=noOfOffers) {
            NSString *verString = [NSString stringWithFormat:@"%.1@",sharedDelegate.versionString];
            serverURL = [[NSString alloc]initWithFormat:@"%@/deals/search?type=A&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@&pageIndex=%i&noOfdeals=0&restName=&address=&version=%@&userId=%@",SERVER_URL,[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],[addressArray objectAtIndex:2],[sharedDelegate.searchingradies objectForKey:@"radies"],pageIndex,verString,[sharedDelegate.userdetails  valueForKey:@"userId"]];
            
            NSString *terString = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
            [self sendASIHTTPRequest:url];
            pageIndex++;
        }
        else{
            nearTableView.tableFooterView.hidden=YES;
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
/*
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    NSString *verString = [NSString stringWithFormat:@"%.1@",sharedDelegate.versionString];
    serverURL = [[NSString alloc]initWithFormat:@"%@/deals/search?type=A&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@&pageIndex=%i&noOfdeals=0&restName=&address=&version=%@&userId=%@",SERVER_URL,[addressArray objectAtIndex:0],[addressArray objectAtIndex:1],[addressArray objectAtIndex:2],[sharedDelegate.searchingradies objectForKey:@"radies"],pageIndex,verString,[sharedDelegate.userdetails  valueForKey:@"userId"]];
    
    NSString *terString = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendASIHTTPRequest:url];
    pageIndex++;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.nearTableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
*/
-(void)dealloc {
    [nearTableView release]; 
    [serverURL release];
    [addressArray release];
    [allEntries release];[ imagesArray  release];
    [details release];
    [currentElement release];[dealid release];
    [noOfdeals release];[dealsfrom release];[cuisine_type_id release];[driving_distance release];[business_name release];[deal_name release];[image_url release];[rest_deal_restrictions release];[deal_description release];[rest_deal_availablestart_date release];[rest_deal_start_date release];[rest_deal_end_date release];[available_start_time release]; [available_end_time release];[available_week_days release];[deal_credit_value release];[location_rest_address release];[address release];[no_deals_available release];
    [nodata_Lable release];
    [reverseGeoCoder release];
    [myGeocoder release];
    [activityIndicatorView release];
    [myLocation release];
    [nearmeDetailVCtrl release];
    [networkQueue release];
    [sharedDelegate release];
    [mapViewCtrl release];
    [networkQueue cancelAllOperations];
    [networkQueue release];

}
@end
