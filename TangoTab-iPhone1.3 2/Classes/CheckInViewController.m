//
//  CheckInViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckInViewController.h"
#import "CheckInXmlParser.h"
#import "defines.h"
#import "FBConnect.h"
#import "TangoTabAppDelegate.h"
#import "ActivityIndicatorView.h"


@implementation CheckInViewController
@synthesize textView,checkInXmlParser,dealDic,elementStack;
@synthesize availableDate;
@synthesize activityIndicatorView;
static NSString* kAppId = @"121440451250508";
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
	_facebook = [[Facebook alloc] init];
	
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	_engine.consumerKey = @"kskZzsSeIEeQ5sahIrtzQ";
	_engine.consumerSecret = @"P9cKFDVw8oAZxMx5rznwzx05ToXWefC8vzyDot7kAQ";

	
	[textView becomeFirstResponder];
	
	availableDate = [[NSString alloc] init];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(add_review:) name:@"add_review" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_review_added:) name:@"review_added" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"review_added_error_occured" object:nil];
	
	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"message",@"errorMessage",nil];
	checkInXmlParser = [[CheckInXmlParser alloc] initWithElementStack:elementStack];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isWantToGoBackInMyDeals) {
		[self.navigationController popViewControllerAnimated:NO];
	}
}

#pragma mark -
#pragma mark Facebook
- (void) login {
	//[_facebook authorize:kAppId permissions:_permissions delegate:self];
	[self publishStream];
}

/**
 * Example of facebook logout
 */
- (void) logout {
	[_facebook logout:self]; 
}
-(IBAction)facebookButtonClicked:(id)sender{

	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	//BOOL canSendToFacebook = [[settingsDictionary valueForKey:@"facebook"] boolValue];
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL canSendToFacebook = [[appDelegate.settingsDict valueForKey:@"facebook"] boolValue];
	
	if (canSendToFacebook) {
		if ([textView.text length]>0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
		}
		
		
		[textView resignFirstResponder];
		if (_fbButton.isLoggedIn) {
			[self logout];
		} else {
			[self login];
		}
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Facebook is switched off in settings. Do you want to switch on it" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
		[alert setTag:333];
		[alert show];
		[alert release];
	}
	
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_permissions =  [[NSArray arrayWithObjects: 
						  @"read_stream", @"offline_access",nil] retain];
	}
	
	return self;
}


- (IBAction) publishStream{
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
														   @"iPhone TangoTab",@"text",@"http://www.facebook.com/apps/application.php?id=121440451250508#!/apps/application.php?id=121440451250508&v=page_getting_started",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								@"Tango Tab", @"name",
								@"TabgoTab App from iPhone", @"caption",
								@"TangoTab HOT Deal :)", @"description",
								//@"http://www.youtube.com/watch?v=NUo-GfoWpJU", @"href",
								nil];
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	
	
	
	NSString *body = [NSString stringWithFormat:@"%@ Restaurant Name: %@ Deal Name: %@ Deal Details: %@ Deal Restrictions: %@ Available Date: %@",textView.text,[dealDic valueForKey:@"business_name"],[dealDic valueForKey:@"deal_name"],[dealDic valueForKey:@"deal_description"],[dealDic valueForKey:@"rest_deal_restrictions"],availableDate];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kAppId, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   body,@"message",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	
	
	[_facebook dialog: @"stream.publish"
			andParams: params
		  andDelegate:self];
	
	
	
}
- (void)dialogDidComplete:(FBDialog*)dialog{
	//[self.label setText:@"publish successfully"];
	[textView becomeFirstResponder];
	
}

-(void)dialogDidNotComplete:(FBDialog *)dialog
{
	[textView becomeFirstResponder];
}

#pragma mark -
#pragma mark Twitter

-(IBAction)twitterButtonClicked:(id)sender{
	
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	//BOOL canSendToTwitter = [[settingsDictionary valueForKey:@"twitter"] boolValue];
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL canSendToTwitter = [[appDelegate.settingsDict valueForKey:@"twitter"] boolValue];
	
	if (canSendToTwitter) {
		if ([textView.text length]>0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];

		}
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
		
		if (controller) 
			[self presentModalViewController: controller animated: YES];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Twitter is switched off in settings. Do you want to switch on it" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
		[alert setTag:444];
		[alert show];
		[alert release];
	}
}

-(void)uploadData
{
	NSString *message = [NSString stringWithFormat:@"%@\n\n #TangoTab HOT Deal – %@; %@",[textView text],[dealDic valueForKey:@"business_name"],[dealDic valueForKey:@"deal_name"]];

	[_engine sendUpdate:message];
	
}

#pragma mark SA_OAuthTwitterController Delegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	[self uploadData];
	//tweets = [[NSMutableArray alloc] init];
	//	[self updateStream:nil];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Authentication Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView setTag:1111];
	[alertView show];
	[alertView release];
	[textView becomeFirstResponder];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Authentication Canceled" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView setTag:2222];
	[alertView show];
	[alertView release];
	[textView becomeFirstResponder];
}

#pragma mark MGTwitterEngineDelegate Methods

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"published Successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView setTag:3333];
	[alertView show];
	[alertView release];
	[textView becomeFirstResponder];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {

	
}

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
	
	
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
	
	
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	

}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
	

}


#pragma mark -
#pragma mark Mail
-(IBAction)sendMail:(id)sender{
	
	if ([textView.text length] >0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
	}
	
	//	[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController setNavigationBarHidden:YES];	
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}


// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet {
	
	//Creating instance of MFMailComposeViewController
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	//setting delegate to self
	picker.mailComposeDelegate = self;
	
	//	if ([emailTextField.text length] > 0) {
	//		NSArray *toArray = [NSArray arrayWithObjects:[emailTextField text],nil];
	//		[picker setToRecipients:toArray];
	//	}
	
	
	//setting subject of the email
	[picker setSubject:@"TangoTab HOT Deal"];
	
	NSString *body = [NSString stringWithFormat:@"<html>"
					  "<body>"
					  "<font size=\"2\" color=\"black\" face=\"Verdana\">%@</font><br><br>"
					  "<font size=\"2\" color=\"green\" face=\"Arial\">Restaurant Name: </font>"
					  "<font size=\"2\" color=\"black\" face=\"Verdana\">%@</font><br>"
					  "<font size=\"2\" color=\"green\" face=\"Arial\">Deal Name: </font>"
					  "<font size=\"2\" color=\"black\" face=\"Verdana\">%@</font><br>"
					  "<font size=\"2\" color=\"green\" face=\"Arial\">Deal Details: </font>"
					  "<font size=\"2\" color=\"black\" face=\"Verdana\">%@</font><br>"
					  "</body>"
					  "</html>",textView.text,[dealDic valueForKey:@"business_name"],[dealDic valueForKey:@"deal_name"],[dealDic valueForKey:@"deal_description"]];
	
	//	NSString *body = [NSString stringWithFormat:@"%@ Restaurant Name: %@ Deal Name: %@ Deal Details: %@ Deal Restrictions: %@ Available Date: %@",textView.text,[dealDic valueForKey:@"business_name"],[dealDic valueForKey:@"deal_name"],[dealDic valueForKey:@"deal_description"],[dealDic valueForKey:@"rest_deal_restrictions"],availableDate];
	
	[picker setMessageBody:body isHTML:YES];
	
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//	NSString *status;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//			status = @"Mail Cancelled";
			break;
		case MFMailComposeResultSaved:
			//			status = @"Mail Saved";
			break;
		case MFMailComposeResultSent:
			//			status = @"Mail Sent";
			
			//		[[NSNotificationCenter defaultCenter] postNotificationName:@"refer_friend" object:self userInfo:nil];
			break;
		case MFMailComposeResultFailed:
			//			status = @"Mail Failed";
			break;
		default:
			break;
	}
	
	
	[self dismissModalViewControllerAnimated:YES];
	
	//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:status delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//	[alert show];
	//	[alert release];
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController setNavigationBarHidden:NO];
	[self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
}

//http://localhost:9090/tangotab/services/deals/refer?username=admin@tangotab.com&password=naveen&emailId=machava.vas@gmail.com&timestamp=2011-13-09 2006:22:45
// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:?cc=,&subject=";
	NSString *body = @"&body=";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark -
#pragma mark Sms Composer

-(IBAction)sendSms:(id)sender {
	
	if ([textView.text length] >0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
	}
	
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	
	if (messageClass != nil) { 			
		if ([messageClass canSendText]) {
			[self displaySMSComposerSheet];
		}
		else {	
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Device not configured to send SMS" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Device not configured to send SMS" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

-(void)displaySMSComposerSheet 
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	NSString *body = [NSString stringWithFormat:@"%@\n\nTangoTab HOT Deal: %@ - %@ %@",textView.text,[dealDic valueForKey:@"business_name"],[dealDic valueForKey:@"deal_name"],[dealDic valueForKey:@"deal_description"]];
	
	[picker setBody:body];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
				 didFinishWithResult:(MessageComposeResult)result {
	switch (result)
	{
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultSent:
			
			break;
		case MessageComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

-(void)add_review:(NSNotification *)pNotification{
	
		//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		//NSMutableDictionary *settingsDictionary;
		//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
		//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
		
		//NSString *emailId = [settingsDictionary valueForKey:@"userName"];
		//NSString *password = [settingsDictionary valueForKey:@"password"];
    
        TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
        NSString *emailId = [appDelegate.settingsDict valueForKey:@"username"];
        NSString *password = [appDelegate.settingsDict valueForKey:@"password"];
    
    
		NSString *serviceURL = [NSString stringWithFormat:@"%@/deals/addreview?emailId=%@&password=%@&dealId=%@&rating=0&comment=%@",SERVER_URL,emailId,password,[dealDic valueForKey:@"deal_id"],textView.text];
		[checkInXmlParser loadFromURL:serviceURL];
	
	[self showActivityIndicatorView];
	
}

- (void)handle_review_added:(NSNotification *)note
{	
	
//	NSString *resultString = [[note userInfo] objectForKey:@"message"];	
	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	[self stopActivityIndicatorView];
//	[self account_for_empty_results];	
	
}

//- (void)account_for_empty_results
//{
//}
-(void)handle_network_timeout:(NSNotification *)note
{
	[self stopActivityIndicatorView];
}

- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];
	
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	if(alertView.tag == 333 && buttonIndex == 1){
		
        
		//[settingsDictionary setValue:[NSNumber numberWithBool:1] forKey:@"facebook"];
		//[settingsDictionary writeToFile:mydictpath atomically:YES];
        
        [appDelegate.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"facebook"];
        [appDelegate saveObject:appDelegate.settingsDict];
		
//		if ([textView.text length]>0) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
//		}
//		[textView resignFirstResponder];
//		if (_fbButton.isLoggedIn) {
//			[self logout];
//		} else {
//			[self login];
//		}
		
		
	}
	else if(alertView.tag == 444 && buttonIndex == 1){
		//[settingsDictionary setValue:[NSNumber numberWithBool:1] forKey:@"twitter"];
		
		//[settingsDictionary writeToFile:mydictpath atomically:YES];
        [appDelegate.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"facebook"];
        [appDelegate saveObject:appDelegate.settingsDict];
		
		if ([textView.text length]>0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
				
		}
			
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
			
		if (controller) 
			[self presentModalViewController: controller animated: YES];

		
	}
	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 324)];
		[self.view addSubview:activityIndicatorView];
		[self.navigationController.navigationBar setUserInteractionEnabled:NO];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];
	}
}

-(void)stopActivityIndicatorView{
	[self.navigationController.navigationBar setUserInteractionEnabled:YES];

	[self.tabBarController.tabBar setUserInteractionEnabled:YES];
	[activityIndicatorView removeActivityIndicator];
}

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
	[checkInXmlParser release];
	[_engine release];
	[activityIndicatorView release];
	[availableDate release];
	[textView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"add_review" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"review_added" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"review_added_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
    [super dealloc];
}


@end
