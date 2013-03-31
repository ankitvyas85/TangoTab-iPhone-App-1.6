//
//  ForgetPasswordViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@implementation ForgetPasswordViewController

@synthesize emailText;
@synthesize activityIndicatorView;
@synthesize tempdic;
@synthesize currentelement;
@synthesize password,success,phonenumber;
@synthesize sharedDelegate;

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
    sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    tempdic = [[NSMutableDictionary alloc] init];
    currentelement=[[NSString alloc]init];
   
}


-(NSMutableDictionary *) smlParser 
{
    
    NSString *serviceURL = [NSString stringWithFormat:@"%@/forgotpassword/checkuser?emailId=%@",sharedDelegate.activeServerUrl,emailText.text];
    
    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:serviceURL]];
   
    NSXMLParser *parser=[[NSXMLParser alloc]initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    
    return tempdic;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentelement = elementName;
	if ([elementName isEqualToString:@"details"]) {
        success=[[NSMutableString alloc]init];
        password=[[NSMutableString alloc]init];
        phonenumber=[[NSMutableString alloc]init];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstrign = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentelement isEqualToString:@"success"]) {
        [success appendString:terstrign];
    }
    else if ([currentelement isEqualToString:@"password"]) {
        [password appendString:terstrign];
    }
    else if ([currentelement isEqualToString:@"phonenumber"]) {
        [phonenumber appendString:terstrign];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    tempdic = [[NSMutableDictionary alloc]init ];
    if ([elementName isEqualToString:@"details"]) {
        [tempdic setValue:success forKey:@"success"];
        [tempdic setValue:password forKey:@"password"];
        [tempdic setValue:phonenumber forKey:@"phonenumber"];
    }
}


-(IBAction)send:(id)sender 
{
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
       // 
        if ([emailText.text length] == 0) {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Enter Email Id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
        }
        else if(![self validateEmail:emailText.text]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide Valid Email Format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        else{
            
        
            NSMutableDictionary *detailsDic =  [self smlParser];
            if ([[detailsDic valueForKey:@"success"] isEqualToString:@"true"]) {
                NSError *error = nil;
                if (![[GANTracker sharedTracker] trackEvent:@"Forgot Password Buttton"
                                                     action:@"TrackEvent"
                                                      label:@"Forgot Password"
                                                      value:-1
                                                  withError:&error]) {
                    NSLog(@"Error Occured");
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Your password has been sent to your Email Id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert setTag:10];
                [alert show];
                [alert release];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please enter your valid Email Id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert setTag:11];
                [alert show];
                [alert release];
            }
        }
    }
    
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 10) {
        if (buttonIndex == 0) {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    if ([alertView tag]==11) {
        if (buttonIndex==0) {
        }
    }
}

-(IBAction)Cancel:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES]; 
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc {
    [tempdic release];
    [currentelement release];
    [password release];
    [success release];
    [phonenumber release];
    [activityIndicatorView release];
    [emailText release];
}

@end
 