//
//  SignUpViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController

@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize emailTextField;
@synthesize passWordTextField;
@synthesize zipCodeTextField;
@synthesize phoneNumberTextField;
@synthesize agreeCheckBox;
@synthesize shiftForKeyboard,backgroundView;
@synthesize webData;
@synthesize currentString;
@synthesize signupResult;
@synthesize activityindicatter;
@synthesize objPrivacy,objTerms;
@synthesize sharedDelegate;

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
    phoneNumberTextField.delegate=self;
    zipCodeTextField.delegate=self;
    sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(IBAction)back:(id)sender{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)agreeCheckBoxButtonClicked:(id)sender{
    [firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
	if ([agreeCheckBox isSelected]) {
		[agreeCheckBox setSelected:NO];
	}
	else{
		[agreeCheckBox setSelected:YES];
	}	
}

-(IBAction)signUpButtonClicked:(id)sender {
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionality will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
        
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Email Id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Password should be more than 8 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

        else if([zipCodeTextField.text length] > 7){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Zip / Post Code Should be max of 7 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        else if ([phoneNumberTextField.text length] > 0) {
            if([phoneNumberTextField.text length]<12){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Valid Mobile Number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
        }
        if(![agreeCheckBox isSelected]){
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
                webData = [[NSMutableData data] retain];
                
            }
            NSError *error = nil;
            if (![[GANTracker sharedTracker] trackEvent:@"Sign Up Button"
                                                 action:@"TrackEvent"
                                                  label:@"Sign Up"
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            
            [self showActivityIndicatorView];
        }
    }
}


-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	[webData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
	[webData appendData:data];
	
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error
{
    [self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert setTag:1];
	[alert show];
	[alert release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSXMLParser *parser=[[NSXMLParser alloc]initWithData:webData];
    [parser setDelegate:self];
    [parser parse];

}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentString=[[NSMutableString alloc]init];
    currentString=[elementName mutableCopy];
    if ([elementName isEqualToString:@"message"]) {
        signupResult=[[NSMutableString alloc]init];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
        
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentString isEqualToString:@"message"]) {
        [signupResult appendString:terstring];
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];
    if ([signupResult isEqualToString:@"You have Signed Up Successfully."]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:signupResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:111];
		[alert show];
		[alert release];
    }
    if ([signupResult isEqualToString:@"Email already exists."]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:signupResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:222];
		[alert show];
		[alert release];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==111) {
        [self dismissModalViewControllerAnimated:YES];
    }
    if (alertView.tag==222) {
        emailTextField.text=nil;
        passWordTextField.text=nil;
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
-(BOOL)valideZipcode:(NSString *)candidate{
    NSString *compare=@"[A-Z0-9a-z]*";
    NSPredicate *zip=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",compare];
    return [zip evaluateWithObject:candidate];
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
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField==zipCodeTextField) {
        NSString *compare=@"[A-Z0-9a-z]*";
        NSPredicate *zip=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",compare];
        if ([zip evaluateWithObject:string] || [string isEqualToString:@" "]) {
        NSString *str=zipCodeTextField.text;
        NSArray *arr=[str componentsSeparatedByString:@" "];
        if ([arr count]>=2) {
            if ([string isEqualToString:@" "] ) {
                return NO;
            }
            else{
            return YES;
            }
        }
        else{
            return YES;
        }
    }
        else{
            return NO;
        }
    }
    
    if (textField==phoneNumberTextField) {
        NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-"];
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSMutableString *someString=NULL;
        int charCountAdd = [newString length];
        int charCount=[newString length];
        int charCountDelete = [newString length];
        if ([newString rangeOfCharacterFromSet:[numSet invertedSet]].location != NSNotFound
            ||  charCount > 12) {
            return NO;
        }
        if (charCountAdd == 7 || charCountAdd == 3) {
            newString = [newString stringByAppendingString:@"-"];
            charCount++;
        }
        if (charCountDelete == 8 || charCountDelete == 4||charCountDelete==7||charCountDelete==3) {
            if(charCountDelete == 8){
                if ([newString characterAtIndex:7]=='-') {
                    newString = [newString substringToIndex:7];
                    charCount--;
                }
                else
                {
                    someString=[newString mutableCopy];
                    [someString insertString:@"-" atIndex:7];
                    charCount++; 
                }
            }
            else if(charCountDelete == 4){
                if ([newString characterAtIndex:3]=='-') {
                    newString = [newString substringToIndex:3];
                    
                    charCount--;
                }
                else
                {
                    someString=[newString mutableCopy];
                    [someString insertString:@"-" atIndex:3];
                    charCount++; 
                }
            }
            else if(charCountDelete == 7){
                if (string.length==0) {
                    newString = [newString substringToIndex:7];
                    charCount--;  
                }
            }
            else if(charCountDelete == 3){
                if (string.length==0) {
                    newString = [newString substringToIndex:3];
                    
                    charCount--;
                }
            }
            
        }
        if (someString==NULL) {
            textField.text = newString;
        }else
        {
            textField.text=someString;
        }
        
        return NO;
    }
    else
    {
        return YES;
    }
   
}
-(IBAction)privacyPolicyButtonClicked:(id)sender{
    [firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
    
	objPrivacy = [[PrivacyPolicyViewController alloc] initWithNibName:@"PrivacyPolicyViewController" bundle:[NSBundle mainBundle]];
	objPrivacy.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:objPrivacy animated:YES];
	
}

-(IBAction)termsOfUseButtonClicked:(id)sender{
    [firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
	objTerms = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:[NSBundle mainBundle]];
    objTerms.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:objTerms animated:YES];

}
#pragma mark -
#pragma mark Scrolling textFields

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	CGRect textViewRect = [self.backgroundView.window convertRect:textField.bounds fromView:textField];
	CGFloat bottomEdge = textViewRect.origin.y + textViewRect.size.height;
	if (bottomEdge >= 200) {
		
		CGRect viewFrame = self.backgroundView.frame;
		self.shiftForKeyboard = bottomEdge - 200.0f;
		viewFrame.origin.y -= self.shiftForKeyboard;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3];
		[self.backgroundView setFrame:viewFrame];
		[UIView commitAnimations];
        
	} else {
		self.shiftForKeyboard = 0.0f;
	}
	
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	
	[textField resignFirstResponder];
	CGRect viewFrame = self.backgroundView.frame;
	viewFrame.origin.y += self.shiftForKeyboard;
	
	self.shiftForKeyboard = 0.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	[self.backgroundView setFrame:viewFrame];
	[UIView commitAnimations];
}

//-(IBAction)returnClicked:(id)sender{
//	[firstNameTextField resignFirstResponder];
//	[lastNameTextField resignFirstResponder];
//	[emailTextField resignFirstResponder];
//	[passWordTextField resignFirstResponder];
//	[phoneNumberTextField resignFirstResponder];
//	[zipCodeTextField resignFirstResponder];
//}

-(IBAction)backgroundClicked:(id)sender{
	[firstNameTextField resignFirstResponder];
	[lastNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passWordTextField resignFirstResponder];
	[phoneNumberTextField resignFirstResponder];
	[zipCodeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityindicatter])
	{
		if (activityindicatter) {
			[activityindicatter release];
			activityindicatter = nil;
		}
		activityindicatter = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityindicatter adjustFrame:CGRectMake(0,0, 320, 480)];
		[self.view addSubview:activityindicatter];
	}
}

-(void)stopActivityIndicatorView{
    
	[activityindicatter removeActivityIndicator];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [firstNameTextField release];
    [lastNameTextField release];
    [emailTextField release];
    [passWordTextField release];
    [zipCodeTextField release];
    [phoneNumberTextField release];
    [agreeCheckBox release];
    [currentString release];
    [signupResult release];
    [activityindicatter release];
    [objTerms release];
    [objPrivacy release];
    [sharedDelegate release];
    [webData release];
}
@end
