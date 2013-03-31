//
//  SignUpViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"
#import "PrivacyPolicyViewController.h"
#import "TermsOfUseViewController.h"
#import "SignUpXmlParser.h"
#import "defines.h"

@implementation SignUpViewController
@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize emailTextField;
@synthesize passWordTextField;
@synthesize confirmPasswordTextField;
@synthesize zipCodeTextField;
@synthesize phoneNumberTextField;
@synthesize agreeCheckBox;
@synthesize shiftForKeyboard;
@synthesize webData;
@synthesize signUpXmlParser;
@synthesize activityIndicatorView;

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
	self.title = @"Sign up";
	
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(reloadAfterParsing_signUp_account:) name:@"reloadAfterParsing_signUp_account" object:nil];
	[nc addObserver:self selector:@selector(fail_to_parse_data:) name:@"fail_to_parse_data" object:nil];

}
-(IBAction)agreeCheckBoxButtonClicked:(id)sender{
	if ([agreeCheckBox isSelected]) {
		[agreeCheckBox setSelected:NO];
	}
	else{
		[agreeCheckBox setSelected:YES];
	}
	
}
-(IBAction)signUpButtonClicked:(id)sender{

	if ([firstNameTextField.text length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide First Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([lastNameTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Last Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([emailTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if(![self validateEmail:emailTextField.text]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Valid Email Format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([passWordTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([passWordTextField.text length] <= 7){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Password should be more than 8 charecters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([confirmPasswordTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Confirm Password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if(![passWordTextField.text isEqualToString:confirmPasswordTextField.text]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Confirm Password doesnt match to Password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([zipCodeTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Zip / Post Code" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([zipCodeTextField.text length] > 6){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Zip / Post Code Should be max of 6 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if([phoneNumberTextField.text length] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Mobile Number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if(![self validatePhoneNumber:phoneNumberTextField.text]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Valid Mobile Number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if(![agreeCheckBox isSelected]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Agree Privacy policy and terms of use" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else {
		
		NSString *soapMessage = [NSString stringWithFormat:
								 @"<signup>"
								 "<firstname>%@</firstname>"
								 "<lastname>%@</lastname>"
								 "<email>%@</email>"
								 "<password>%@</password>"
								 "<mobileno>%@</mobileno>"
								 "<zipcode>%@</zipcode>"
								 "</signup>",firstNameTextField.text, lastNameTextField.text, emailTextField.text, passWordTextField.text, phoneNumberTextField.text, zipCodeTextField.text];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/signup",SERVER_URL]];
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
		[theRequest setHTTPMethod:@"PUT"];
		[theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
		
		NSURLConnection *theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
		
		
		if(theConnection)
		{
            //webData = [NSMutableData dataWithCapacity:200];
			webData = [[NSMutableData data] retain];
			
		}
		else 
		{
			
		}	
		
		[self showActivityIndicatorView];
		
	}

}




-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	[webData setLength:0];
	NSHTTPURLResponse * httpResponse;
	
	httpResponse = (NSHTTPURLResponse *) response;
	
	NSLog(@"myGeoTrackingViewController  : HTTP error %zd", (ssize_t) httpResponse.statusCode);
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
	[webData appendData:data];
	
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert setTag:1];
	[alert show];
	[alert release];
	[self stopActivityIndicatorView];
	
	[connection release];
	[webData release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
	[theXML release];
	
	if (signUpXmlParser) {
		[signUpXmlParser release];
		signUpXmlParser = nil;
	}
	signUpXmlParser = [[SignUpXmlParser alloc] initWithData:webData];
	[signUpXmlParser.xmlParser parse];
	
	[connection release];
	[webData release];
}


-(void)reloadAfterParsing_signUp_account:(NSNotification *)pNotification{
	
	[self stopActivityIndicatorView];
	
	NSString *resultString = [[pNotification userInfo] objectForKey:@"message"];
	
	if ([resultString isEqualToString:@"Sign up successfull"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:111];
		[alert show];
		[alert release];
	}
	else if ([resultString isEqualToString:@"Email already exists"]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:222];
		[alert show];
		[alert release];
	}

		 
}
-(void)fail_to_parse_data:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == 111 && buttonIndex == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}
	else if(alertView.tag == 222 && buttonIndex == 0){
		[passWordTextField setText:@""];
		[confirmPasswordTextField setText:@""];
	}
}


#pragma mark -
#pragma mark Validations

- (BOOL) validatePhoneNumber: (NSString *) candidate {
    NSString *emailRegex = @"[0-9]{10}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}

-(BOOL) isPasswordValid:(NSString *)pwd{
	if ( [pwd length] <= 7) return NO;  // too long or too short
	NSRange rang;
	rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
	if ( !rang.length ) return NO;  // no letter
	rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
	if ( !rang.length )  return NO;  // no number;
	return YES;
}


-(IBAction)privacyPolicyButtonClicked:(id)sender{
	PrivacyPolicyViewController *objPrivacy = [[PrivacyPolicyViewController alloc] init];
	[self.navigationController pushViewController:objPrivacy animated:YES];
	[objPrivacy release];
}
-(IBAction)termsOfUseButtonClicked:(id)sender{
	TermsOfUseViewController *objTerms = [[TermsOfUseViewController alloc] init];
	[self.navigationController pushViewController:objTerms animated:YES];
	[objTerms release];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Scrolling textFields

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	CGRect textViewRect = [self.view.window convertRect:textField.bounds fromView:textField];
	CGFloat bottomEdge = textViewRect.origin.y + textViewRect.size.height;
	if (bottomEdge >= 200) {
		
		CGRect viewFrame = self.view.frame;
		self.shiftForKeyboard = bottomEdge - 200.0f;
		viewFrame.origin.y -= self.shiftForKeyboard;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3];
		[self.view setFrame:viewFrame];
		[UIView commitAnimations];
		
		
	} else {
		self.shiftForKeyboard = 0.0f;
	}
	
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	
	[textField resignFirstResponder];
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += self.shiftForKeyboard;
	
	self.shiftForKeyboard = 0.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	[self.view setFrame:viewFrame];
	[UIView commitAnimations];
}

-(IBAction)returnClicked:(id)sender{
	[firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[confirmPasswordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
}

-(IBAction)backgroundClicked:(id)sender{
	[firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[confirmPasswordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
}


- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:self.activityIndicatorView])
	{
		if (self.activityIndicatorView) {
			[self.activityIndicatorView release];
			self.activityIndicatorView = nil;
		}
        
   		self.activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
		[self.activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 416)];
		[self.view addSubview:self.activityIndicatorView];
	}
}

-(void)stopActivityIndicatorView{
	[self.activityIndicatorView removeActivityIndicator];
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
	[activityIndicatorView release];
	[signUpXmlParser release];
	[firstNameTextField release];
	[lastNameTextField release];
	[emailTextField release];
	[passWordTextField release];
	[confirmPasswordTextField release];
	[zipCodeTextField release];
	[phoneNumberTextField release];
	[agreeCheckBox release];
    [webData release];
    
    [super dealloc];
}


@end
