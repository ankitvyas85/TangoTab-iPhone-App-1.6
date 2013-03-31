//
//  ReviewsViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReviewsViewController.h"
#import "AddReviewViewController.h"
#import "defines.h"
#import "ActivityIndicatorView.h"
#import "TangoTabAppDelegate.h"
#import "ReviewTableViewCell.h"

@implementation ReviewsViewController
@synthesize reviewsArray,reviewTableView;
@synthesize activityIndicatorView,dealDic;
@synthesize addReview;
@synthesize noDataLabel;
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
	
	self.title = @"Reviews";
	
	addReview = [[UIBarButtonItem alloc] initWithTitle:@"Add Review" style:UIBarButtonItemStyleBordered target:self action:@selector(addReviewButtonClicked:)];
	[self.navigationItem setRightBarButtonItem:addReview];
	
	noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 200, 20)];
	[noDataLabel setText:@"No Reviews Found"];
	[noDataLabel setAlpha:0.5];
	
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(get_reviews:) name:@"get_reviews" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_reviews_loaded:) name:@"reviews_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"reviews_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"reviews_data_Parser_Error" object:nil];

	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"reviews",@"review",@"user_rating",@"user_comment",@"errorMessage",nil];
	reviewsXmlParser = [[ReviewsXmlParser alloc] initWithElementStack:elementStack];	
	serviceURL = [[NSString alloc] init];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
}



-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.wantToGoBack || appDelegate.isGoBackToplaces) {
		[self.navigationController popViewControllerAnimated:NO];
	}
	else {
		if ([reviewsArray count]>0) {
			[reviewsArray removeAllObjects];
		}
		[self.reviewTableView reloadData];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"get_reviews" object:self userInfo:nil];
	}

}


#pragma mark -
#pragma mark Getting Reviews 
-(void)get_reviews:(NSNotification *)pNotification
{
	[noDataLabel removeFromSuperview];
	
	
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	serviceURL = [NSString stringWithFormat:@"%@/deals/reviews?dealId=%@",SERVER_URL,[appDelegate.wantItDic valueForKey:@"id"]];
	
	
	[reviewsXmlParser loadFromURL:serviceURL];
	
	[self showActivityIndicatorView];
}

-(void)handle_network_timeout:(id)sender{
	[self stopActivityIndicatorView];
}

- (void)handle_reviews_loaded:(NSNotification *)note
{	
	self.navigationItem.hidesBackButton = NO;

	reviewsArray = [[note userInfo] objectForKey:@"array"];	
	
	[self stopActivityIndicatorView];
	
	[self account_for_empty_results];
	
	self.reviewTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.reviewTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	
	
}

- (void)account_for_empty_results
{
	if ([reviewsArray count] == 0) {
		[self.view addSubview:noDataLabel];
	}
	
}

- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
}

-(void)addReviewButtonClicked:(id)sender{
	AddReviewViewController *addReviewViewController = [[AddReviewViewController alloc] init];
	addReviewViewController.dealDic = self.dealDic;
	[self.navigationController pushViewController:addReviewViewController animated:YES];
	[addReviewViewController release];
}

#pragma mark -
#pragma mark tableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [reviewsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
    ReviewTableViewCell *cell =(ReviewTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ReviewTableViewCell" owner:self options:nil];
		cell = objReviewTableViewCell;
		
		}
	NSMutableDictionary *dic = [reviewsArray objectAtIndex:indexPath.row];
	cell.userCommentLabel.text = [dic valueForKey:@"user_comment"];
	[cell.userCommentLabel setNumberOfLines:3];
	cell.userCommentLabel.font = [UIFont systemFontOfSize:12.0];
	cell.userCommentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
	cell.userCommentLabel.adjustsFontSizeToFitWidth = YES;
	cell.userCommentLabel.minimumFontSize = 5.0;
	
	cell.detailTextLabel.font = [UIFont systemFontOfSize:25];
	
	rating = [[dic valueForKey:@"user_rating"]intValue];
	if (rating == 1) {
		cell.ratingImageView.image = [UIImage imageNamed:@"1.png"];
	}
	else if (rating == 2) {
		cell.ratingImageView.image = [UIImage imageNamed:@"2.png"];
	}
	else if (rating == 3) {
		cell.ratingImageView.image = [UIImage imageNamed:@"3.png"];
	}
	else if (rating == 4) {
		cell.ratingImageView.image = [UIImage imageNamed:@"4.png"];
	}
	else if (rating == 5) {
		cell.ratingImageView.image = [UIImage imageNamed:@"5.png"];
	}
	
	cell.reviewImageView.image = [UIImage imageNamed:@"photo(2).jpg"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{	
	return 90;
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
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
		[self.view addSubview:activityIndicatorView];
		[self.addReview setEnabled:NO];
		[self.navigationController.navigationBar setUserInteractionEnabled:NO];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];

	}
	
}

-(void)stopActivityIndicatorView{
	[self.addReview setEnabled:YES];
	[self.navigationController.navigationBar setUserInteractionEnabled:YES];
	[self.tabBarController.tabBar setUserInteractionEnabled:YES];
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
	[dealDic release];
	[noDataLabel release];
	[addReview release];
	[activityIndicatorView release];
	[reviewTableView release];
	[reviewsArray release];
	[reviewsXmlParser release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"get_reviews" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"reviews_loaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"reviews_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"reviews_data_Parser_Error" object:nil];

    [super dealloc];
}


@end
