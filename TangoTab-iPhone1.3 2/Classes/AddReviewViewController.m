//
//  AddReviewViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddReviewViewController.h"
#import "defines.h"
#import "TangoTabAppDelegate.h"
#import "ActivityIndicatorView.h"

@implementation AddReviewViewController
@synthesize image1,image2, image3, image4, image5,image;
@synthesize textView1,restaurantNameLabel;
@synthesize doneButton, sendButton;
@synthesize dealDic;
@synthesize elementStack;
@synthesize checkInXmlParser;
@synthesize activityIndicatorView;
#define X 135.0000
#define X1 152.5000
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
	
	self.title = @"Add Review";
	[restaurantNameLabel setText:[dealDic valueForKey:@"business_name"]];
	
	sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonClicked:)];
	[self.navigationItem setRightBarButtonItem:sendButton];
	
//	doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
	
	[textView1 setDelegate:self];
	[textView1 becomeFirstResponder];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(add_review:) name:@"add_review" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_review_added:) name:@"review_added" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"review_added_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"addReview_data_Parser_Error" object:nil];

	
	elementStack = [[NSMutableArray alloc] initWithObjects:@"message",@"errorMessage",nil];
	checkInXmlParser = [[CheckInXmlParser alloc] initWithElementStack:elementStack];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (appDelegate.wantToGoBack || appDelegate.isGoBackToplaces) {
		[self.navigationController popViewControllerAnimated:NO];
	}
	else {
		[restaurantNameLabel setText:[appDelegate.wantItDic valueForKey:@"business_name"]];
	}


}
-(void)sendButtonClicked:(id)sender{
	if ([textView1.text length] >0 && rating !=0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"add_review" object:self userInfo:nil];
	}
	else if([textView1.text length]==0 && rating == 0){
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Provide some feedback and rating" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView setTag:333];
		[alertView show];
		[alertView release];
	}
	else if([textView1.text length]==0){
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Provide some feedback" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView setTag:333];
		[alertView show];
		[alertView release];
	}
	else if(rating == 0){
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Provide some rating" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView setTag:333];
		[alertView show];
		[alertView release];
	}
}

-(void)add_review:(NSNotification *)pNotification
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	//NSString *emailId = [settingsDictionary valueForKey:@"username"];
	//NSString *password = [settingsDictionary valueForKey:@"password"];
    
    NSString *emailId = [appDelegate.settingsDict valueForKey:@"username"];
	NSString *password = [appDelegate.settingsDict valueForKey:@"password"];
	
	NSString *serviceURL = [NSString stringWithFormat:@"%@/deals/addreview?emailId=%@&password=%@&dealId=%@&rating=%i&comment=%@",SERVER_URL,emailId,password,[appDelegate.wantItDic valueForKey:@"id"],rating,textView1.text];
	[checkInXmlParser loadFromURL:serviceURL];
	[self showActivityIndicatorView];
	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0 && alertView.tag == 333) {
		
	}
	else if (buttonIndex == 0 && alertView.tag == 111) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)handle_review_added:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
	NSString *resultString = [[note userInfo] objectForKey:@"message"];	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert setTag:111];	
	[alert show];
	[alert release];
	
	//[self account_for_empty_results];	
	
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

//- (void)textViewDidBeginEditing:(UITextView *)textView{
//	[self.navigationItem setRightBarButtonItem:doneButton];
//}
/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}
*/


//-(void)doneButtonClicked:(id)sender{
//	[textView1 resignFirstResponder];
//	[self.navigationItem setRightBarButtonItem:sendButton];
//}

#pragma mark -
#pragma mark Rating

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [[event allTouches] anyObject];
	
	CGPoint touchLocation = [touch locationInView:self.view];

	if ([touch view] == image) {
		if (touchLocation.x >X && touchLocation.x<X+35 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image3 setImage:[UIImage imageNamed:@"emptstart.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 1;
		}
		else if (touchLocation.x>X+35 && touchLocation.x<X+70) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"emptstart.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 2;
		}
		else if (touchLocation.x >X+70 && touchLocation.x<X+105 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 3;
		}
		else if (touchLocation.x >X+105 && touchLocation.x<X+140 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 4;
		}
		else if (touchLocation.x >X+140 && touchLocation.x<X+175 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image5 setImage:[UIImage imageNamed:@"redsttar.png"]];
			
			rating = 5;
		}
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [[event allTouches] anyObject];
	
	CGPoint touchLocation = [touch locationInView:self.view];

	if ([touch view] == image) {
		if (touchLocation.x >X1-35 && touchLocation.x<X1 ) {
			[image1 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image2 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image3 setImage:[UIImage imageNamed:@"emptstart.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 0;
		}
		else if (touchLocation.x >X1 && touchLocation.x<X1+35 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image3 setImage:[UIImage imageNamed:@"emptstart.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 1;
		}
		else if (touchLocation.x >X1+35 && touchLocation.x<X1+70) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"emptstart.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 2;
		}
		else if (touchLocation.x >X1+70 && touchLocation.x<X1+105 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"emptstart.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 3;
		}
		else if (touchLocation.x >X1+105 && touchLocation.x<X1+140 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image5 setImage:[UIImage imageNamed:@"emptstart.png"]];
			
			rating = 4;
		}
		else if (touchLocation.x >X1+140 && touchLocation.x<X1+175 ) {
			[image1 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image2 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image3 setImage:[UIImage imageNamed:@"redsttar.png"]]; 
			[image4 setImage:[UIImage imageNamed:@"redsttar.png"]];
			[image5 setImage:[UIImage imageNamed:@"redsttar.png"]];
			
			rating = 5;
		}
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
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
		[sendButton setEnabled:NO];
		[self.navigationController.navigationBar setUserInteractionEnabled:NO];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];
	}
}

-(void)stopActivityIndicatorView{
	[sendButton setEnabled:YES];
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
	[activityIndicatorView release];
//	[elementStack release];
	[dealDic release];
	[doneButton release];
	[sendButton release];
	[restaurantNameLabel release];
	[textView1 release];
	[image release];
	[image1 release];
	[image2 release];
	[image3 release];
	[image4 release];
	[image5 release];
	[checkInXmlParser release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"add_review" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"review_added" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"review_added_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addReview_data_Parser_Error" object:nil];

	[super dealloc];

}


@end
