//
//  PlacesViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesTableViewCell.h"
#import "MapViewController.h"
#import "OverlayViewController.h"
#import "PlacesXmlParser.h"
#import "ActivityIndicatorView.h"
#import "TangoTabAppDelegate.h"
#import "defines.h"
#import "WantItViewController.h"
#import "AsyncImageView.h"

@implementation PlacesViewController

@synthesize placesTableViewCell;
@synthesize placesTableView;
@synthesize segmentedControl;
@synthesize copyPlacesArray,placesSearchBar,searching,letUserSelectRow,ovController;
@synthesize locationController,searchTempArray,activityIndicatorView;
@synthesize mapButton;
@synthesize elementStack, placesParser;
@synthesize placesArray,lastSeenTimeStampString;
@synthesize noDataLabel;
@synthesize serviceURL;
@synthesize searchingRadius;
@synthesize addressArray;

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
	
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(get_places:) name:@"get_places" object:nil];	
	[nc addObserver:self selector:@selector(get_places_byLocation:) name:@"get_places_byLocation" object:nil];
	
	[nc addObserver:self selector:@selector(handle_places_loaded:) name:@"places_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"places_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"data_Parser_Error" object:nil];

	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"deal_details",@"last_seen_timestamp",@"deal",@"business_name",@"rest_deal_restrictions",@"deal_name",@"cuisine_type",@"rest_deal_start_date",@"rest_deal_end_date",@"available_start_time",@"available_end_time",@"available_week_days",@"deal_description",@"deal_credit_value",@"location_rest_address",@"address",@"image_url",@"no_deals_available"@"errorMessage",nil];
	if (placesParser) {
		[placesParser release];
		placesParser = nil;
	}
	self.placesParser = [[PlacesXmlParser alloc] initWithElementStack:elementStack];	
    
    if ([self.searchingRadius isEqualToNumber:[NSNumber numberWithInt:0]] || (self.searchingRadius==nil)){
        self.searchingRadius = [NSNumber numberWithFloat:10.0];
    }
    
    placesParser.searchingRadius = self.searchingRadius;
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
	self.copyPlacesArray = [[NSMutableArray alloc] init];
	self.searchTempArray=[[NSMutableArray alloc] init];
	self.serviceURL = [[NSString alloc] init];
	
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	
	[self.navigationItem setTitle:@"Near Me"];
	
	locationController = [[LocationController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
	
	//segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Around me",@"Going...",@"New",nil]];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Near Me",nil]];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStylePlain];
	[segmentedControl setTintColor:[UIColor clearColor]];//colorWithRed:0.034 green:0.739 blue:0.034 alpha:1.0]];
	[segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setSelectedSegmentIndex:0];
	//[self.navigationItem setTitleView:segmentedControl];
	
	mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(mapButtonClicked)];
	[self.navigationItem setRightBarButtonItem:mapButton];
		
	placesSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searching = NO;
	letUserSelectRow = YES;
	
	isFirstLoaded = YES;
	
	noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, 300, 120)];
	[noDataLabel setNumberOfLines:5];
	[noDataLabel setAlpha:0.5];
	
	lastSeenTimeStampString = [[NSString alloc] init];
	
	[nc addObserver:self selector:@selector(handleError:) name:@"places_error_occured" object:nil];

}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];

	[noDataLabel removeFromSuperview];
	
 	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isAddressForSearch = NO;
	appDelegate.isGoBackToplaces = NO;
    appDelegate.isDealsWithLocationInPlaces = YES;
    
	if(appDelegate.isFromSearch)
	{
		WantItViewController *wantItViewController = [[WantItViewController alloc] init];
		TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.isFromSearch = NO;
		wantItViewController.isFirstFromPlaces = YES;
		NSString *urlString = [appDelegate.wantItDic valueForKey:@"image_url"];
		NSURL *url = [NSURL URLWithString:urlString];
		wantItViewController.imageURL = url;
		[self.navigationController pushViewController:wantItViewController animated:YES];
		[wantItViewController release];
	}
	
//[locationController.locationManager startUpdatingLocation];
    
    if ([self.placesArray count]>0) {
			[self.placesArray removeAllObjects];
		}
	[self.placesTableView reloadData];
	
	if ([self.segmentedControl selectedSegmentIndex] == 0) {
		//[self showActivityIndicatorView];
		
		[locationController.locationManager startUpdatingLocation];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"get_places" object:self userInfo:nil];
	}

}


-(void)locationUpdate:(CLLocation *)location{
//	[self showActivityIndicatorView];
	[locationController.locationManager stopUpdatingLocation];

}

-(void)locationError:(NSError *)error{
	[locationController.locationManager stopUpdatingLocation];
	[self.view addSubview:noDataLabel];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"get_places_byLocation" object:self userInfo:nil];
}

-(void)reverseGeoCoder:(NSString *)addressString{
	[locationController.reverseGeoCoder cancel];
	//NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:addressString forKey:@"location"];
    NSDictionary *d = [NSDictionary dictionaryWithObject:addressString forKey:@"location"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"get_places_byLocation" object:self userInfo:d];
}

-(void)reverseGeoCoderError:(NSError *)error{
	[locationController.reverseGeoCoder cancel];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"get_places_byLocation" object:self userInfo:nil];
	[self.view addSubview:noDataLabel];

}

-(void)segmentedControlValueChanged{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[noDataLabel removeFromSuperview];

	if ([self.placesArray count]>0) {
		[self.placesArray removeAllObjects];
	}
	
	[self.placesTableView reloadData];
	if ([self.segmentedControl selectedSegmentIndex] == 0) {
		appDelegate.isDealsWithLocationInPlaces = YES;
	//	[self showActivityIndicatorView];
		if ([CLLocationManager locationServicesEnabled]) {
			[locationController.locationManager startUpdatingLocation];
		}
		else {
			[noDataLabel setText:@"Sorry, we are unable to show you deals around you as we are unable to determine your current location. Please enable location services in your settings or search using the search button on the bottom of this screen."];
			[self.view addSubview:noDataLabel];
		}

	}
	else {
	//	appDelegate.isDealsWithLocationInPlaces = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"get_places" object:self userInfo:nil];
	}
}

-(void)get_places_byLocation:(NSNotification *)pNotification{
	NSString *zipCodeString = [[pNotification userInfo] objectForKey:@"location"];
	zipCodeString = [zipCodeString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    NSArray *arr = [zipCodeString componentsSeparatedByString:@";"];
    
    self.addressArray = [NSArray arrayWithArray:arr];
	
    if ([[self.addressArray objectAtIndex:0] isEqualToString:@""] && [[self.addressArray objectAtIndex:1] isEqualToString:@""]) {
		[noDataLabel setText:@"Sorry can't find your current location"];
		[self.view addSubview:noDataLabel];
	}
	else {
        if ([self.searchingRadius isEqualToNumber:[NSNumber numberWithInt:0]] || (self.searchingRadius==nil)){
            self.searchingRadius = [NSNumber numberWithFloat:10.0];
            self.placesParser.searchingRadius = self.searchingRadius;
        }
        
        //serviceURL = [NSString stringWithFormat:@"%@/deals/nearby?city=%@&zipcode=%@&coordinate=%@searchingradius=%@",SERVER_URL,[addressArray objectAtIndex:0],[addressArray objectAtIndex:1], [addressArray objectAtIndex:2], searchingRadius];
        self.serviceURL = [NSString stringWithFormat:@"%@/neardeals/aroundme?type=A&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@",SERVER_URL,[addressArray objectAtIndex:0],[self.addressArray objectAtIndex:1], [self.addressArray objectAtIndex:2], self.searchingRadius];
        
        //serviceURL = [NSString stringWithFormat:@"%@/deals/nearby?city=%@&zipcode=%@&coordinate=%@searchingradius=%@",SERVER_URL,[addressArray objectAtIndex:0],@"75025", [addressArray objectAtIndex:2], self.searchingRadius];
        
		[self.placesParser loadFromURL:self.serviceURL];
        
		[self showActivityIndicatorView];		
	}
}

-(void)get_places:(NSNotification *)pNotification
{
    if ([self.searchingRadius isEqualToNumber:[NSNumber numberWithInt:0]] || (self.searchingRadius==nil)){
        self.searchingRadius = [NSNumber numberWithFloat:10.0];
    }
    
	switch (self.segmentedControl.selectedSegmentIndex) {
		case 0:
			break;
		case 1:
        {
            self.serviceURL = [NSString stringWithFormat:@"%@/neardeals/aroundme?type=G&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@",SERVER_URL,[self.addressArray objectAtIndex:0],[self.addressArray objectAtIndex:1], [self.addressArray objectAtIndex:2], self.searchingRadius];
        }   
			break;
		case 2:
        {
			self.serviceURL = [NSString stringWithFormat:@"%@/neardeals/aroundme?type=N&city=%@&zipcode=%@&coordinate=%@&searchingradius=%@",SERVER_URL,[self.addressArray objectAtIndex:0],[self.addressArray objectAtIndex:1], [self.addressArray objectAtIndex:2], self.searchingRadius];
        }
			break;	
		default:
			break;
	}
	
	[self.placesParser loadFromURL:self.serviceURL];
	[self showActivityIndicatorView];
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)handle_network_timeout:(id)sender{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isDealsWithLocationInPlaces) {
		appDelegate.isDealsWithLocationInPlaces = NO;
	}
	[self stopActivityIndicatorView];
}


- (void)handleError:(NSNotification *)note
{	
	
	[self stopActivityIndicatorView];
}

- (void)handle_places_loaded:(NSNotification *)note
{	
	int a,b;
	self.placesArray = [[note userInfo] objectForKey:@"array"];	

	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isDealsWithLocationInPlaces) {
		int n = [self.placesArray count];
		for (int i = 0; i < n-1; i++){
			for (int j = i+1; j < n; j++){
				a = [[[self.placesArray objectAtIndex:i] valueForKey:@"distance_currentLocation"] intValue];
				b = [[[self.placesArray objectAtIndex:j] valueForKey:@"distance_currentLocation"] intValue];
				if (a > b){
					[self.placesArray exchangeObjectAtIndex:i withObjectAtIndex:j];
				}
			}
			
		}
	}
	
	[self stopActivityIndicatorView];
	[self account_for_empty_results];
	self.placesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.placesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)account_for_empty_results
{
	if([self.placesArray count] == 0)
	{
		switch (self.segmentedControl.selectedSegmentIndex) {
			case 0:
				if ([CLLocationManager locationServicesEnabled]) {
					[noDataLabel setText:@"Sorry, there are no deals around your current location. Please broaden your search criteria using the search button on the bottom of this screen."];
				}
				else {
					[noDataLabel setText:@"Sorry, we are unable to show you deals around you as we are unable to determine your current location. Please enable location services in your settings or search using the search button on the bottom of this screen."];
				}
				break;
			case 1:
				[noDataLabel setText:@"Sorry, there are no deals that are about to expire around your current location. Please broaden your search criteria using the search button on the bottom of this screen."];
				break;
			case 2:
				[noDataLabel setText:@"Sorry, there are no new deals around your current location. Please broaden your search criteria using the search button on the bottom of this screen or check back soon."];
				break;
			default:
				break;
		}
		[mapButton setEnabled:NO];
		[self.view addSubview:noDataLabel];
		
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.searching)
		return [self.searchTempArray count];
	else {

		return [self.placesArray count];

	}
}

-(void)displayTableView{

	[self.searchTempArray removeAllObjects];
	NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:self.placesArray];
    
    if ([self.searchingRadius isEqualToNumber:[NSNumber numberWithInt:0]] || (self.searchingRadius==nil)){
        self.searchingRadius = [NSNumber numberWithFloat:10.0];
    }
    
	for (int i=0; i<[self.copyPlacesArray count]; i++) {
		for (int j=0; j<[tempArray count]; j++) {
            NSMutableDictionary	*dic = [tempArray objectAtIndex:j];

            if ([[self.copyPlacesArray objectAtIndex:i] isEqualToString:[dic valueForKey:@"business_name"]]|| [[self.copyPlacesArray objectAtIndex:i] isEqualToString:[dic valueForKey:@"cuisine_type"]]) {
			
                NSDictionary *dic = [tempArray objectAtIndex:j];
                NSNumber *num =  [dic valueForKey:@"distance_currentLocation"];
            
            
                if ([num doubleValue]<[self.searchingRadius doubleValue]) {
                    [self.searchTempArray addObject:[tempArray objectAtIndex:j]];
                }
			
                [tempArray removeObjectAtIndex:j];
            }
			
        }
    }
	[tempArray release];
	
}

#define ASYNC_IMAGE_TAG 9999

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";

    NSMutableDictionary *dic;
	AsyncImageView *asyncImageView = nil;

		PlacesTableViewCell *cell = (PlacesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"PlacesTableViewCell" owner:self options:nil];
			cell = placesTableViewCell;
			CGRect frame;
			frame.origin.x = 2;
			frame.origin.y = 40;
			frame.size.width = 70;
			frame.size.height = 65;
			asyncImageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
			asyncImageView.tag = ASYNC_IMAGE_TAG;
			[cell.contentView addSubview:asyncImageView];
			frame.origin.x = 2 + 10;
			frame.size.width = 70;
			asyncImageView.x = 34;
			asyncImageView.y = 32;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else {
			asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
		}
	
		
		if(searching) {
			
			dic = [searchTempArray objectAtIndex:indexPath.row];
			[cell.restaurantNameLabel setText:[dic valueForKey:@"business_name"]];
			[cell.dealNameLabel setText:[dic valueForKey:@"deal_name"]];
			[cell.restaurantType setText:[dic valueForKey:@"cuisine_type"]];
            
            [cell.drivingDistanceLabel setText:[NSString stringWithFormat:@"%.1f miles", [[dic valueForKey:@"driving_distance"] doubleValue]]];// 

			NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
			[readDateFormat setDateFormat:READING_DATE_FORMAT];
			
			NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
			[writingFormater setDateFormat:WRITING_DATE_FORMAT];
			
			NSString *startDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_start_date"],[dic valueForKey:@"available_start_time"]];
			NSString *endDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_end_date"],[dic valueForKey:@"available_end_time"]];
			
			NSDate *startDate = [readDateFormat dateFromString:startDateString];
			NSDate *endDate = [readDateFormat dateFromString:endDateString];
			
			NSString *dateString = [NSString stringWithFormat:@"%@ to %@",[writingFormater stringFromDate:startDate],[writingFormater stringFromDate:endDate]];
            
            dateString = [dateString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
			[writingFormater release];
			[readDateFormat release];

			//[cell.timeStampLabel setText:dateString];
			[cell.dealsAvailableLabel setText:[NSString stringWithFormat:@"%@ deals available",[dic valueForKey:@"no_deals_available"]]];
			NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
			NSURL *url = [NSURL URLWithString:urlString];
			[asyncImageView loadImageFromURL:url];

		}
		else {
			dic = [self.placesArray objectAtIndex:indexPath.row];
			[cell.restaurantNameLabel setText:[dic valueForKey:@"business_name"]];
			[cell.dealNameLabel setText:[dic valueForKey:@"deal_name"]];
			[cell.restaurantType setText:[dic valueForKey:@"cuisine_type"]];

            [cell.drivingDistanceLabel setText:[NSString stringWithFormat:@"%.1f miles", [[dic valueForKey:@"driving_distance"] doubleValue]]];// distance_currentLocation
			
			NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
			[readDateFormat setDateFormat:READING_DATE_FORMAT];
			NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
			[writingFormater setDateFormat:WRITING_DATE_FORMAT];
			
			NSString *startDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_start_date"],[dic valueForKey:@"available_start_time"]];
			NSString *endDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_end_date"],[dic valueForKey:@"available_end_time"]];

			NSDate *startDate = [readDateFormat dateFromString:startDateString];
			NSDate *endDate = [readDateFormat dateFromString:endDateString];
						
			NSString *dateString = [NSString stringWithFormat:@"%@ to %@",[writingFormater stringFromDate:startDate],[writingFormater stringFromDate:endDate]];
            
            dateString = [dateString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
			[writingFormater release];
			[readDateFormat release];
			
			//[cell.timeStampLabel setText:dateString];
			[cell.dealsAvailableLabel setText:[NSString stringWithFormat:@"%@ deals available",[dic valueForKey:@"no_deals_available"]]];
			
			NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
			//urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; 
			NSURL *url = [NSURL URLWithString:urlString];
			[asyncImageView loadImageFromURL:url];
			
		}
		return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	WantItViewController *wantItViewController = [[WantItViewController alloc] init];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.wantItDic = [self.placesArray objectAtIndex:indexPath.row];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if(searching) {
	   dic = [self.searchTempArray objectAtIndex:indexPath.row];
    }
    else {
        dic= [self.placesArray objectAtIndex:indexPath.row];
    }
    
	NSString *urlString = [dic valueForKey:@"image_url"];
    NSURL *url = [NSURL URLWithString:urlString];
    wantItViewController.imageURL = url;
	[self.navigationController pushViewController:wantItViewController animated:YES];
	[wantItViewController release];
	
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	return 120;
}

-(void)mapButtonClicked{
	MapViewController *mapViewController = [[MapViewController alloc] init];

	if ([self.placesArray count]>0 && !self.searching) {
		
		mapViewController.placesMapArray = self.placesArray;
		
		[self.navigationController pushViewController:mapViewController animated:YES];
	}
	else if([self.searchTempArray count]>0 && self.searching){
		mapViewController.placesMapArray = self.searchTempArray;
		[self.navigationController pushViewController:mapViewController animated:YES];

	}
	[mapViewController release];

}


#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(self.searching)
		return;
	
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:[NSBundle mainBundle]];
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;	
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
	
	[self.placesTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
	self.searching = YES;
	letUserSelectRow = NO;
	self.placesTableView.scrollEnabled = NO;
	
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	//Remove all objects first.
	[self.copyPlacesArray removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		self.searching = YES;
		letUserSelectRow = YES;
		self.placesTableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.placesTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		self.searching = NO;
		letUserSelectRow = NO;
		self.placesTableView.scrollEnabled = NO;
	}
	
	[self.placesTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[placesSearchBar resignFirstResponder];
	[placesSearchBar setShowsSearchResultsButton:YES];
}

- (void) searchTableView {
	
	NSString *searchText = placesSearchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *dictionary in self.placesArray)
	{
		NSString *string = [dictionary objectForKey:@"business_name"];
		[searchArray addObject:string];
		
	}
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[self.copyPlacesArray addObject:sTemp];
	}
	for (NSDictionary *dictionary in self.placesArray)
	{
		NSString *string = [dictionary objectForKey:@"cuisine_type"];
        if (string != nil)
            [searchArray addObject:string];
		
	}
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[self.copyPlacesArray addObject:sTemp];
	}
	
	[searchArray release];
	searchArray = nil;
	[self displayTableView];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	placesSearchBar.text = @"";
	[placesSearchBar resignFirstResponder];
	[placesSearchBar setShowsSearchResultsButton:NO];
	letUserSelectRow = YES;
	searching = NO;
		
	self.placesTableView.scrollEnabled = YES;
		
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
		
	[self.placesTableView reloadData];
		
	
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
		[self.segmentedControl setUserInteractionEnabled:NO];
		[mapButton setEnabled:NO];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, 320, 480)];
		[self.view addSubview:activityIndicatorView];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];
	}
}

-(void)stopActivityIndicatorView{
	[self.mapButton setEnabled:YES];
	[self.segmentedControl setUserInteractionEnabled:YES];
	[activityIndicatorView removeActivityIndicator];
	[self.tabBarController.tabBar setUserInteractionEnabled:YES];
//	[activityIndicatorView release];
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
    placesTableViewCell = nil;
    placesTableView = nil;
}


- (void)dealloc {
	[placesTableViewCell release];
	[placesTableView release];
	[segmentedControl release];
	[copyPlacesArray release];
	[placesSearchBar release];
	[ovController release];
	[locationController release];
	[searchTempArray release];
	[activityIndicatorView release];
	[mapButton release];
//	[elementStack release];
	[placesParser release];
	[placesArray release];
	[lastSeenTimeStampString release];
	[noDataLabel release];
	[serviceURL release];
    [searchingRadius release];
    [addressArray release]; 
    [activityIndicatorView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"get_places" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"get_places_byLocation" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"places_loaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"places_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"places_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"data_Parser_Error" object:nil];

    [super dealloc];
}


@end
