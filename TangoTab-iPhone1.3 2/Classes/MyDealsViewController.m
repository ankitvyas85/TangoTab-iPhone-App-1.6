//
//  MyDealsViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDealsViewController.h"
#import "RedeemViewController.h"
#import "MyDealsXmlParser.h"
#import "MyDealsMapViewController.h"
#import "OverlayViewController.h"
#import "NetworkTimeout.h"
#import "TangoTabAppDelegate.h"
#import "defines.h"
#import "MyDealsTableviewCell.h"
#import "AsyncImageView.h"

@implementation MyDealsViewController


@synthesize myDealsTableView,myDealsArray;

@synthesize elementStack,myDealsParser,serviceURL,segmentedControl,mapButton;
@synthesize myDealsSearchBar,searching,letUserSelectRow,ovController,copyMyDealsArray,searchTempArray;
@synthesize activityIndicatorView,myCLController,noDataLabel;
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
	[nc addObserver:self selector:@selector(get_myDeals:) name:@"get_myDeals" object:nil];	
	[nc addObserver:self selector:@selector(get_myDeals_byLocation:) name:@"get_myDeals_byLocation" object:nil];

	
	[nc addObserver:self selector:@selector(handle_myDeals_loaded:) name:@"myDeals_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(invalid_user:) name:@"invalid_user" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"myDeals_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"myDeals_data_Parser_Error" object:nil];

	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"mydeal_details",@"detail",@"con_res_id",@"deal_id",@"deal_name",@"cuisine_type",@"deal_description",@"deal_restrictions",@"start_time",@"end_time",@"business_name",@"reserved_time_stamp",@"address",@"image_url"@"message",@"errorMessage",nil];
	myDealsParser = [[MyDealsXmlParser alloc] initWithElementStack:elementStack];
	
	serviceURL = [[NSString alloc] init];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
	
	copyMyDealsArray=[[NSMutableArray alloc] init];
	searchTempArray=[[NSMutableArray alloc] init];
	
	
	myCLController = [[MyCLController alloc] init];
	myCLController.delegate = self;
	[self.navigationItem setTitle:@"TangoTab"];
		
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
//	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.034 green:0.739 blue:0.034 alpha:1.0]];
	[self.navigationItem setTitle:@"My Offers"];
/*	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Around me",@"Going...",@"New",nil]];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
//	UIColor *color = [UIColor colorWithRed:0.034 green:0.739 blue:0.034 alpha:1.0];
	[segmentedControl setTintColor:[UIColor grayColor]];
	[segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setSelectedSegmentIndex:0];
	[self.navigationItem setTitleView:segmentedControl];
*/	
	
	mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(mapButtonClicked)];
	[self.navigationItem setRightBarButtonItem:mapButton];
	
	myDealsSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searching = NO;
	letUserSelectRow = YES;
	
	isFirstLoaded = NO;

	
	zipCode = [[NSString alloc] init];
	
	noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 320, 40)];
	[noDataLabel setText:@"You have not selected any deals. Please search for a deal and reserve it"];
	[noDataLabel setNumberOfLines:2];
	[noDataLabel setAlpha:0.5];
}


-(void)locationUpdate:(CLLocation *)location{
//	[self showActivityIndicatorView];
	[myCLController.locationManager stopUpdatingLocation];
}

-(void)locationError:(NSError *)error{
	[myCLController.locationManager stopUpdatingLocation];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals_byLocation" object:self userInfo:nil];

}

-(void)reverseGeoCoder:(NSString *)addressString{
	[myCLController.reverseGeoCoder cancel];
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:addressString forKey:@"location"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals_byLocation" object:self userInfo:d];

	//isWithLocation = YES;
}
-(void)reverseGeoCoderError:(NSError *)error{
	[myCLController.reverseGeoCoder cancel];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals_byLocation" object:self userInfo:nil];

}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.objTabBarController setSelectedIndex:3];
}
*/
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];

	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication]delegate];
	appDelegate.isAddressForSearch = NO;
	appDelegate.isWantToGoBackInMyDeals = NO;
		if ([myDealsArray count]>0) {
			[myDealsArray removeAllObjects];
		}
	[self.myDealsTableView reloadData];
	/*
	if ([self.segmentedControl selectedSegmentIndex] == 0) {
		[self showActivityIndicatorView];
		[myCLController.locationManager startUpdatingLocation];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals" object:self userInfo:nil];
	}
	*/
	[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals" object:self userInfo:nil];

}

-(void)invalid_user:(NSNotification *)note{
	[self stopActivityIndicatorView];	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[[note userInfo] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}
/*
-(void)get_myDeals_byLocation:(NSNotification *)pNotification{
	
	[noDataLabel removeFromSuperview];
	NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSMutableDictionary *settingsDictionary;
	NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	NSString *emailId = [settingsDictionary valueForKey:@"userName"];
	NSString *password = [settingsDictionary valueForKey:@"password"];
	
	NSString *zipCodeString = [[pNotification userInfo] objectForKey:@"location"];

	if ([emailId length] == 0 || [password length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Email ID and Password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {
		switch (self.segmentedControl.selectedSegmentIndex) {
			case 0:
				if ([zipCodeString isEqualToString:@"(null)"]) {
					serviceURL = [NSString stringWithFormat:@"%@/mydeals/nearby?emailId=%@&password=%@&zipcode=",SERVER_URL,emailId,password];
				}
				else {
					serviceURL = [NSString stringWithFormat:@"%@/mydeals/nearby?emailId=%@&password=%@&zipcode=%@",SERVER_URL,emailId,password,zipCode];
				}
				break;
			case 1:
				break;
			case 2:
				break;	
			default:
				break;
		}
		
		
	
		[myDealsParser loadFromBundle:serviceURL];
	}

	
}
*/
-(void)get_myDeals:(NSNotification *)pNotification{
	
	[noDataLabel removeFromSuperview];
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	//NSString *emailId = [settingsDictionary valueForKey:@"username"];
	//NSString *password = [settingsDictionary valueForKey:@"password"];
    
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *emailId = [appDelegate.settingsDict valueForKey:@"username"];
	NSString *password = [appDelegate.settingsDict valueForKey:@"password"];
    
	
/*	NSLog(@"%@",[settingsDictionary valueForKey:@"myDealsLastSeenDate"]);
	switch (self.segmentedControl.selectedSegmentIndex) {
		case 0:
			
			break;
		case 1:
			serviceURL = [NSString stringWithFormat:@"%@/mydeals/expiringby?emailId=%@&password=%@",SERVER_URL,emailId,password];
			break;
		case 2:
			serviceURL = [NSString stringWithFormat:@"%@/mydeals/recent?emailId=%@&password=%@&orderedtimestamp=%@",SERVER_URL,emailId,password,[settingsDictionary valueForKey:@"myDealsLastSeenDate"]];
			NSDate *now = [NSDate date];
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			[settingsDictionary setValue:[df stringFromDate:now] forKey:@"myDealsLastSeenDate"]; 
			[settingsDictionary writeToFile:mydictpath atomically:YES];
			NSLog(@"+++++++++++++++");
			NSLog(@"%@",[df stringFromDate:now]);
			[df release];
			break;	
		default:
			break;
	}
*/	
	serviceURL = [NSString stringWithFormat:@"%@/mydeals/alldeals?emailId=%@&password=%@",SERVER_URL,emailId,password];

	[myDealsParser loadFromURL:serviceURL];
	[self showActivityIndicatorView];

}

- (void)handle_myDeals_loaded:(NSNotification *)note{	
	
	myDealsArray = [[note userInfo] objectForKey:@"array"];	
	
	for (int i = 0; i < [myDealsArray count]; i++) {
	
	}
	
	NSDate *a;
	NSDate *b;
	
	NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
	[dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	int firstDistance, secondDistance;
	int n = [myDealsArray count];
	for (int i = 0; i < n-1; i++){
		for (int j = i+1; j < n; j++){
			
			a = [dateFormater dateFromString:[[myDealsArray objectAtIndex:i] valueForKey:@"reserved_time_stamp"]];
			b = [dateFormater dateFromString:[[myDealsArray objectAtIndex:j] valueForKey:@"reserved_time_stamp"]];
			switch ([a compare:b]){
				case NSOrderedAscending:
					
				
					break;
				case NSOrderedSame:
					firstDistance = [[[myDealsArray objectAtIndex:i] valueForKey:@"distance_currentLocation"] intValue];
					secondDistance = [[[myDealsArray objectAtIndex:j] valueForKey:@"distance_currentLocation"] intValue];
					if (firstDistance > secondDistance) {
						[myDealsArray exchangeObjectAtIndex:i withObjectAtIndex:j];
					}
					break;
				case NSOrderedDescending:
					[myDealsArray exchangeObjectAtIndex:i withObjectAtIndex:j];
					
					break;
			}
		}
	}	
	[dateFormater release];

	for (int i = 0; i < [myDealsArray count]; i++) {

	}

	[self stopActivityIndicatorView];
	[self account_for_empty_results];
	self.myDealsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.myDealsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	
}

- (void)account_for_empty_results{
	if([myDealsArray count] == 0){
		
		[self.view addSubview:noDataLabel];
	}
}
-(void)handle_network_timeout:(NSNotification *)note{
	[self stopActivityIndicatorView];
}

- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
}
/*
-(void)segmentedControlValueChanged{
	if ([myDealsArray count]>0) {
		[myDealsArray removeAllObjects];
	}
		
	[self.myDealsTableView reloadData];
	
	if ([self.segmentedControl selectedSegmentIndex] == 0) {
		[self showActivityIndicatorView];
		[myCLController.locationManager startUpdatingLocation];

	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"get_myDeals" object:self userInfo:nil];		
	}
	
}
*/
-(void)mapButtonClicked{
	
	MyDealsMapViewController *mapView = [[MyDealsMapViewController alloc] init];
	
	if ([myDealsArray count]>0 && !searching) {
		
		mapView.myDealsMapArray = myDealsArray;
		[self.navigationController pushViewController:mapView animated:YES];
	}
	else if([searchTempArray count]>0 && searching){
		mapView.myDealsMapArray = searchTempArray;
		[self.navigationController pushViewController:mapView animated:YES];
		
	}
	[mapView release];
	
}
#pragma mark -
#pragma mark tableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (searching)
		return [searchTempArray count];
	else
		return [myDealsArray count];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	return 70;
}

#define ASYNC_IMAGE_TAG 999

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	AsyncImageView *asyncImageView = nil;
    MyDealsTableviewCell *cell = (MyDealsTableviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"MyDealsTableviewCell" owner:self options:nil];
		cell = objMyDealsTableViewCell;
		CGRect frame;
		frame.origin.x = 2;
		frame.origin.y = 2;
		frame.size.width = 70;
		frame.size.height = 65;
		asyncImageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
		asyncImageView.tag = ASYNC_IMAGE_TAG;
		asyncImageView.x = 35;
		asyncImageView.y = 32.5;
		[cell.contentView addSubview:asyncImageView];
		frame.origin.x = 40 + 10;
		frame.size.width = 100;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		asyncImageView = (AsyncImageView *) [cell.contentView viewWithTag:ASYNC_IMAGE_TAG];
		//       label = (UILabel *) [cell.contentView viewWithTag:LABEL_TAG];
	}
	
	if (searching){
		NSMutableDictionary *dic = [searchTempArray objectAtIndex:indexPath.row];
		objMyDealsTableViewCell.businessNameLable.text = [dic valueForKey:@"business_name"];
		NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
		[readDateFormat setDateFormat:READING_DATE_FORMAT];
		NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
		[writingFormater setDateFormat:WRITING_DATE_FORMAT];
		
		NSDate *date = [readDateFormat dateFromString:[dic valueForKey:@"reserved_time_stamp"]];
		
		objMyDealsTableViewCell.businessDateLable.text =[NSString stringWithFormat:@"%@, %@ to %@", [writingFormater stringFromDate:date],[dic valueForKey:@"start_time"],[dic valueForKey:@"end_time"]] ;
		[writingFormater release];
		[readDateFormat release];
		
		objMyDealsTableViewCell.dealName.text = [dic valueForKey:@"deal_name"];
		//objMyDealsTableViewCell.businessImageView.image = [UIImage imageNamed:@"default1.jpg"];
		NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[asyncImageView loadImageFromURL:url];
	}
	
	else{
		NSMutableDictionary *dic = [myDealsArray objectAtIndex:indexPath.row];
		objMyDealsTableViewCell.businessNameLable.text = [dic valueForKey:@"business_name"];
		
		NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
		[readDateFormat setDateFormat:READING_DATE_FORMAT];
		NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
		[writingFormater setDateFormat:WRITING_DATE_FORMAT];
		
		NSDate *date = [readDateFormat dateFromString:[dic valueForKey:@"reserved_time_stamp"]];
		
		objMyDealsTableViewCell.businessDateLable.text =[NSString stringWithFormat:@"%@, %@ to %@", [writingFormater stringFromDate:date],[dic valueForKey:@"start_time"],[dic valueForKey:@"end_time"]] ;
		[writingFormater release];
		[readDateFormat release];
		objMyDealsTableViewCell.dealName.text = [dic valueForKey:@"deal_name"];
		//objMyDealsTableViewCell.businessImageView.image = [UIImage imageNamed:@"default1.jpg"];
		NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[asyncImageView loadImageFromURL:url];
	}
	
	return objMyDealsTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
		RedeemViewController *redeemViewController = [[RedeemViewController alloc] init];
		redeemViewController.redeemDic = [myDealsArray objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:redeemViewController animated:YES];
		
		[redeemViewController release];
	
}


#pragma mark -
#pragma mark Search Methods

-(void)displayTableView{
	
	[searchTempArray removeAllObjects];
	NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:myDealsArray];
	for (int i=0; i<[copyMyDealsArray count]; i++) {
		for (int j=0; j<[tempArray count]; j++) {
			
			
			NSMutableDictionary	*dic = [tempArray objectAtIndex:j];
			
			if ([[copyMyDealsArray objectAtIndex:i] isEqualToString:[dic valueForKey:@"business_name"] ]) {
				
				[searchTempArray addObject:[tempArray objectAtIndex:j]];
				[tempArray removeObjectAtIndex:j];
			}
			
		}
		
	}
	[tempArray release];
	
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
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
	
//	ovController.rvController = self;
	
	[self.myDealsTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
	searching = YES;
	letUserSelectRow = NO;
	self.myDealsTableView.scrollEnabled = NO;
	
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	//Remove all objects first.
	[copyMyDealsArray removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		self.myDealsTableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.myDealsTableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		letUserSelectRow = NO;
		self.myDealsTableView.scrollEnabled = NO;
	}
	
	[self.myDealsTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[myDealsSearchBar resignFirstResponder];
	[myDealsSearchBar setShowsSearchResultsButton:YES];
}

- (void) searchTableView {
	
	NSString *searchText = myDealsSearchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *dictionary in myDealsArray)
	{
		NSString *string = [dictionary objectForKey:@"business_name"];
		[searchArray addObject:string];
		
	}
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[copyMyDealsArray addObject:sTemp];
	}
	
	
	[searchArray release];
	searchArray = nil;
	[self displayTableView];
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	myDealsSearchBar.text = @"";
	[myDealsSearchBar resignFirstResponder];
	[myDealsSearchBar setShowsSearchResultsButton:NO];
	letUserSelectRow = YES;
	searching = NO;
	
	self.myDealsTableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
	
	[self.myDealsTableView reloadData];
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
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

- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		[self.segmentedControl setUserInteractionEnabled:NO];
		[mapButton setEnabled:NO];
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 324)];
		[self.view addSubview:activityIndicatorView];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];
	}
}

-(void)stopActivityIndicatorView{
	[self.mapButton setEnabled:YES];
	[self.segmentedControl setUserInteractionEnabled:YES];
	[activityIndicatorView removeActivityIndicator];
	[self.tabBarController.tabBar setUserInteractionEnabled:YES];
}
- (void)dealloc {
	[noDataLabel release];
	[zipCode release];
	[myDealsTableView release];
	[segmentedControl release];
	[myDealsSearchBar release];
	[ovController release];
	[copyMyDealsArray release];
	[searchTempArray release];
	[elementStack release];
	[myDealsParser release];
	[serviceURL release];
	[myDealsArray release];
	//[mapButton release];
	[myCLController release];
	[activityIndicatorView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"get_myDeals" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"get_myDeals_byLocation" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"myDeals_loaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"invalid_user" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"myDeals_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"myDeals_data_Parser_Error" object:nil];

	[super dealloc];

}


@end
