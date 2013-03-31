//
//  RedeemViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RedeemViewController.h"
#import "SettingsViewController.h"
#import "TangoTabAppDelegate.h"
#import "CheckInViewController.h"
#import "defines.h"
#import "MYDealsReviewsViewController.h"

@implementation RedeemViewController
@synthesize redeemDic,textView,reservedIdLabel/*,elementStack,redeemXmlParser*/,useDealBitton,asyncImageView,dealNameLabel,restNameLabel;
@synthesize addressLabel,cusionTypeLabel,dealDescriptionLabel,restrictionLabel,timeStampLabel;
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
	self.title = @"Check In";
	
	NSDateFormatter *readDateFormat = [[NSDateFormatter alloc] init];
	[readDateFormat setDateFormat:READING_DATE_FORMAT];
	NSDateFormatter *writingFormater = [[NSDateFormatter alloc] init];
	[writingFormater setDateFormat:@"EEE, MMM dd yyyy"];
	
	NSDate *date = [readDateFormat dateFromString:[redeemDic valueForKey:@"reserved_time_stamp"]];
		
	[timeStampLabel setText:[NSString stringWithFormat:@"%@ %@ to %@",[writingFormater stringFromDate:date],[redeemDic valueForKey:@"start_time"],[redeemDic valueForKey:@"end_time"]]];
	[writingFormater release];
	[readDateFormat release];
	
	[reservedIdLabel setText:[redeemDic valueForKey:@"con_res_id"]];
	[restNameLabel setText:[redeemDic valueForKey:@"business_name"]];
	[dealNameLabel setText:[redeemDic valueForKey:@"deal_name"]];
	[addressLabel setText:[redeemDic valueForKey:@"address"]];
	[dealDescriptionLabel setText:[redeemDic valueForKey:@"deal_description"]];
	[cusionTypeLabel setText:[redeemDic valueForKey:@"cuisine_type"]];
	[restrictionLabel setText:[redeemDic valueForKey:@"deal_restrictions"]];
	
	NSString *urlString = [NSString stringWithFormat:@"%@",[redeemDic valueForKey:@"image_url"]];
	NSURL *url = [NSURL URLWithString:urlString];
	asyncImageView.x = 40;
	asyncImageView.y = 40;
	[asyncImageView loadImageFromURL:url];
	
	
//	UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Reviews" style:UIBarButtonItemStyleBordered target:self action:@selector(reviewButtonClicked:)];
//	[self.navigationItem setRightBarButtonItem:checkInButton];
//	[checkInButton release];
/*	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(update_dealUsed:) name:@"update_dealUsed" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_deal_used_loaded:) name:@"deal_used_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"update_error_occured" object:nil];
	
	[nc addObserver:self selector:@selector(parserError:) name:@"redeem_data_Parser_Error" object:nil];

	elementStack = [[NSMutableArray alloc] initWithObjects:@"message",@"errorMessage",nil];
	redeemXmlParser = [[RedeemXmlParser alloc] initWithElementStack:elementStack];
	
	[useDealBitton setUserInteractionEnabled:YES];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
*/	
}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isWantToGoBackInMyDeals) {
		[self.navigationController popViewControllerAnimated:NO];
	}
}
//-(void)checkInButtonClicked:(id)sender{
//	CheckInViewController *checkIn = [[CheckInViewController alloc] init];
//	checkIn.dealDic = redeemDic;
//	[self.navigationController pushViewController:checkIn animated:YES];
//	[checkIn release];
//	
//}

//-(IBAction)markDealAsUsedButtonClicked:(id)sender{
//
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"update_dealUsed" object:self userInfo:nil];
//}

//-(void)reviewButtonClicked:(id)sender{
//	MYDealsReviewsViewController *reviewsViewController = [[MYDealsReviewsViewController alloc] init];
//	//reviewsViewController.dealID = [self.wantItDic valueForKey:@"id"];
//	reviewsViewController.dealDic = self.redeemDic;
//	[self.navigationController pushViewController:reviewsViewController animated:YES];
//	[reviewsViewController release];
//}

-(IBAction)checkInButtonClicked:(id)sender{
	CheckInViewController *checkIn = [[CheckInViewController alloc] init];
	checkIn.dealDic = redeemDic;
	[self.navigationController pushViewController:checkIn animated:YES];
	[checkIn release];
}
/*
-(void)update_dealUsed:(NSNotification *)pNotification
{
	NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSMutableDictionary *settingsDictionary;
	NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	NSString *emailId = [settingsDictionary valueForKey:@"userName"];
	NSString *password = [settingsDictionary valueForKey:@"password"];
	
	NSString *serviceURL = [NSString stringWithFormat:@"%@/mydeals/update?emailId=%@&password=%@&conResId=%@",SERVER_URL,emailId,password,[redeemDic valueForKey:@"con_res_id"]];
		
	

	[redeemXmlParser loadFromBundle:serviceURL];
//	[self showActivityIndicatorView];
	
}

- (void)handle_deal_used_loaded:(NSNotification *)note
{	
	
	NSString *result = [[note userInfo] objectForKey:@"message"];	
	
	if ([result isEqualToString:@"Deal has been Used"]) {
		[useDealBitton setUserInteractionEnabled:NO];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:222];
		[alert show];
		[alert release];
	}
	else{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert setTag:111];
	[alert show];
	[alert release];
	}
//	[self stopActivityIndicatorView];
	[self account_for_empty_results];
	
	
}

- (void)account_for_empty_results
{
}
-(void)handle_network_timeout:(NSNotification *)note
{
	
}
*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == 111) {
		TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.objTabBarController setSelectedIndex:3];
	}
	else if(alertView.tag == 222){
		//[self.navigationController popViewControllerAnimated:YES];
	}
	
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
	[useDealBitton release];
	[restrictionLabel release];
	[timeStampLabel release];
	[dealDescriptionLabel release];
	[cusionTypeLabel release];
	[addressLabel release];
	[restNameLabel release];
	[dealNameLabel release];
	[asyncImageView release];
	[reservedIdLabel release];
	[textView release];
	[redeemDic release];
    [super dealloc];
}


@end
