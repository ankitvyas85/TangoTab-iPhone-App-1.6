//
//  FacebookSignup.m
//  TangoTab
//
//  Created by Mark Crutcher on 10/15/12.
//
//

#import "FacebookSignup.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "IsActiveAccount.h"

@implementation FacebookSignup

@synthesize parser, webData, signupResult, currentString, viewController;


- (void) signupWithToken: (NSString *) token email: (NSString *) email firstName: (NSString *) firstName LastName: (NSString *) lastName zipCode: (NSString *) zipCode {
    
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
      
    // manufacture a password
    NSArray *splitEmail = [email componentsSeparatedByString:@"@"];
    NSString *password = @"fbid";
    password = [password stringByAppendingString:[splitEmail objectAtIndex:0]];
    
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<signup>"
                             "<firstname><![CDATA[%@]]></firstname>"
                             "<lastname><![CDATA[%@]]></lastname>"
                             "<email><![CDATA[%@]]></email>"
                             "<password><![CDATA[%@]]></password>"
                             "<mobileno><![CDATA[%@]]></mobileno>"
                             "<zipcode><![CDATA[%@]]></zipcode>"
                             "<promocode><![CDATA[%@]]></promocode>"
                             "</signup>",firstName, lastName, email, password, @"", zipCode,@""];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/signup",sharedDelegate.activeServerUrl]];
    debug_NSLog(@"signup request => %@", [url absoluteString]);
    debug_NSLog(@"signup message => %@", soapMessage);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"PUT"];
    [theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
    if(theConnection)
    {
        self.webData = [[NSMutableData data] retain];
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
    //    [self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert setTag:1];
	[alert show];
	[alert release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.parser=[[NSXMLParser alloc]initWithData:webData];
    [self.parser setDelegate:self];
    [self.parser parse];
    
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
//    [self stopActivityIndicatorView];
    debug_NSLog(@"signup result = %@", signupResult);
    if ([signupResult isEqualToString:@"You have Signed Up Successfully."]) {
         [self.viewController facebookSignupComplete];
    }
    else
//    if ([signupResult isEqualToString:@"Email already exists."]) { // then just signin
//        [self.viewController facebookSignupComplete];
//    }
//    else
    {
         [self.viewController facebookSignupFailed];
    }
}



@end
