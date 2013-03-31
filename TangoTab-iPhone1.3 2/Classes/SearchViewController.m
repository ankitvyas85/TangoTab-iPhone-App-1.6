//
//  SearchViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "defines.h"
#import "TangoTabAppDelegate.h"
#import "SearchTableViewCell.h"
#import "PlacesViewController.h"

@implementation SearchViewController
@synthesize restaurantSearchBar,locationSearchBar,searchArray,searchXmlParser,elementStack,searchTableView;
@synthesize myCLController;
@synthesize activityIndicatorView;
@synthesize noDataLabel;
@synthesize isResSearchBarResign,isLocSearchBarResign;
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
	
	self.title = @"Search";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(search_deals:) name:@"search_deals" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_search_deals_loaded:) name:@"search_deals_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"search_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"search_data_Parser_Error" object:nil];

	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"deal_details",@"deal",@"business_name",@"cuisine_type",@"deal_name",@"rest_deal_restrictions",@"rest_deal_start_date",@"rest_deal_end_date",@"available_start_time",@"available_end_time",@"available_week_days",@"deal_description",@"deal_credit_value",@"location_rest_address",@"address",@"no_deals_available",@"image_url",@"errorMessage",nil];
	searchXmlParser = [[SearchXmlParser alloc] initWithElementStack:elementStack];
	
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
	myCLController = [[SearchLocationController alloc] init];
	myCLController.delegate = self;
	
	noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 20)];
	[noDataLabel setText:@"Sorry, No deals match the search criteria."];
	[noDataLabel setNumberOfLines:1];
	[noDataLabel setAlpha:0.5];
	
	//[self.locationSearchBar setUserInteractionEnabled:NO];

}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.isAddressForSearch = YES;
	appDelegate.isGoBackToplaces = YES;
	
	if([myCLController.locationManager locationServicesEnabled])
	{
		[myCLController.locationManager startUpdatingLocation];
	}
	else {
	}
	//[self showActivityIndicatorView];
	
	isLocSearchBarResign = NO;
	isResSearchBarResign = NO;
}

-(void)locationUpdate:(CLLocation *)location{
	[myCLController.locationManager stopUpdatingLocation];
}

-(void)locationError:(NSError *)error{
	[myCLController.locationManager stopUpdatingLocation];
	[self stopActivityIndicatorView];
}

-(void)reverseGeoCoder:(NSString *)addressString{
	[myCLController.reverseGeoCoder cancel];

	
	addressString = [addressString stringByReplacingOccurrencesOfString:@",(null)" withString:@""];
	addressString = [addressString stringByReplacingOccurrencesOfString:@"(null)," withString:@""];
	addressString = [addressString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
	[self.locationSearchBar setText:addressString];
	[self stopActivityIndicatorView];

}
-(void)reverseGeoCoderError:(NSError *)error{
	[myCLController.reverseGeoCoder cancel];
	[self stopActivityIndicatorView];

}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	if ([searchArray count] >0) {
		[searchArray removeAllObjects];
		[self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

	}
	[restaurantSearchBar resignFirstResponder];
	[locationSearchBar resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"search_deals" object:self userInfo:nil];
	
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[restaurantSearchBar resignFirstResponder];
	[locationSearchBar resignFirstResponder];
	[restaurantSearchBar setText:@""];
	[locationSearchBar setText:@""];
	[searchArray removeAllObjects];
	[noDataLabel removeFromSuperview];
	[self.searchTableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	if (searchBar.tag == 1) {
		if ([restaurantSearchBar.text length] == 0) {
			isResSearchBarResign = YES;
			[restaurantSearchBar resignFirstResponder];
		}
	}
	else if (searchBar.tag == 2){
		if ([locationSearchBar.text length] == 0) {
			isLocSearchBarResign = YES;
			[locationSearchBar resignFirstResponder];
		}
		
	}
	
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	if (searchBar.tag == 1) {
		if (([restaurantSearchBar.text length] == 0) && isResSearchBarResign) {
			isResSearchBarResign = NO;
			[restaurantSearchBar resignFirstResponder];
		}
	}
	else if(searchBar.tag == 2){
		if (([locationSearchBar.text length] == 0) && isLocSearchBarResign) {
			isLocSearchBarResign = NO;
			[locationSearchBar resignFirstResponder];
		}
	}
	
}


-(void)search_deals:(NSNotification *)pNotification
{
	[noDataLabel removeFromSuperview];
	
	NSString *serviceURL = [NSString stringWithFormat:@"%@/deals/search?restName=%@&address=%@",SERVER_URL,restaurantSearchBar.text,locationSearchBar.text];
		
    serviceURL = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];

	[searchXmlParser loadFromURL:serviceURL];
	[self showActivityIndicatorView];
	
}

- (void)handle_search_deals_loaded:(NSNotification *)note
{	
	
	searchArray = [[note userInfo] objectForKey:@"array"];	
	
	[self stopActivityIndicatorView];
	[self account_for_empty_results];
	self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	
}

- (void)account_for_empty_results
{
	[self stopActivityIndicatorView];
	if([searchArray count] == 0)
	{
		[self.view addSubview:noDataLabel];
	}
}
-(void)handle_network_timeout:(NSNotification *)note
{
	[self stopActivityIndicatorView];
}
- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
	
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"SearchTableViewCell" owner:self options:nil];
		cell = objSearchTableViewCell;
    }
	
//	NSMutableDictionary *dic = [searchArray objectAtIndex:indexPath.row];

	NSMutableDictionary *dic = [searchArray objectAtIndex:indexPath.row];
	[cell.restaurantNameLabel setText:[dic valueForKey:@"business_name"]];
	[cell.dealNameLabel setText:[dic valueForKey:@"deal_name"]];
    [cell.restaurantType setNumberOfLines:2]; 
    //[cell.restaurantType setTextAlignment:UITextAlignmentCenter];
	[cell.restaurantType setText:[dic valueForKey:@"cuisine_type"]];
	
	NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
	[readDateFormat setDateFormat:READING_DATE_FORMAT];
	NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
	[writingFormater setDateFormat:WRITING_DATE_FORMAT];
	
	NSString *startDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_start_date"],[dic valueForKey:@"available_start_time"]];
	NSString *endDateString = [NSString stringWithFormat:@"%@ %@:00",[dic valueForKey:@"rest_deal_end_date"],[dic valueForKey:@"available_end_time"]];
	
	NSDate *startDate = [readDateFormat dateFromString:startDateString];
	NSDate *endDate = [readDateFormat dateFromString:endDateString];
	
	//			NSString *date = [startDate descriptionWithLocale:@""];
	
	NSString *dateString = [NSString stringWithFormat:@"%@ to %@",[writingFormater stringFromDate:startDate],[writingFormater stringFromDate:endDate]];
	[writingFormater release];
	[readDateFormat release];
	
	//[cell.timeStampLabel setText:dateString];
	[cell.dealsAvailableLabel setText:[NSString stringWithFormat:@"%@ deals available",[dic valueForKey:@"no_deals_available"]]];
	NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
	NSURL *url = [NSURL URLWithString:urlString];
	cell.asyncImageView.x = 35;
	cell.asyncImageView.y = 35;
	[cell.asyncImageView loadImageFromURL:url];
	return cell;
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	return 120;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isFromSearch = YES;
	appDelegate.wantToGoBack = YES;
	appDelegate.isGoBackToplaces = NO;
	appDelegate.wantItDic = [searchArray objectAtIndex:indexPath.row];
	appDelegate.objTabBarController.selectedIndex = 1;
	
}
- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		//[self.segmentedControl setUserInteractionEnabled:NO];
		//[mapButton setEnabled:NO];
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 324)];
		[self.view addSubview:activityIndicatorView];
	}
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)stopActivityIndicatorView{
	//[self.mapButton setEnabled:YES];
	//[self.segmentedControl setUserInteractionEnabled:YES];
	[activityIndicatorView removeActivityIndicator];
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
	[noDataLabel release];
	[activityIndicatorView release];
	[myCLController release];
	[searchTableView release];
	[elementStack release];
	[searchXmlParser release];
	[searchArray release];
	[restaurantSearchBar release];
	[locationSearchBar release];
    [super dealloc];
}


@end
