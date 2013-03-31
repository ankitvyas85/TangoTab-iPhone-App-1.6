//
//  WantItViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WantItViewController.h"
#import"ReviewsViewController.h"
#import "defines.h"
#import "ShareItViewController.h"
#import "MapViewController.h"
#import "TangoTabAppDelegate.h"
#import "ActivityIndicatorView.h"

@implementation WantItViewController
@synthesize restaurantNameLabel,restaurantLocationLabel,dealNameLabel,creditValueLabel,cuisineTypeIdLabel,dealTimeButton,wantItDic,reviewsArray,dateAndTimeLabel;
@synthesize elementStack1,wantItXmlParser,dealDescriptionLabel,dealRestriction;
@synthesize resultDateString;
@synthesize myImageView;
@synthesize imageURL;
@synthesize datePicker;
@synthesize emailTextField;
@synthesize isFirstFromPlaces;
@synthesize shiftForKeyboard;
@synthesize referalEmailId;
@synthesize activityIndicatorView,reviewsButton;
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
	self.title = @"Offer";
	
	if (isFirstFromPlaces) {
        
        UIImage *shuffleButtonDisabledImage = [UIImage imageNamed:@"back_button.png"];
        UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shuffleButton setImage:shuffleButtonDisabledImage forState:UIControlStateNormal];
        
        shuffleButton.frame = CGRectMake(0, 0, shuffleButtonDisabledImage.size.width, shuffleButtonDisabledImage.size.height);
        [shuffleButton addTarget:self action:@selector(gotoSearch) forControlEvents:UIControlEventTouchUpInside]; 
        UIBarButtonItem *shuffleBarItem = [[UIBarButtonItem alloc]	initWithCustomView:shuffleButton];
        
        self.navigationItem.leftBarButtonItem = shuffleBarItem;
	}
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSString *urlString = [appDelegate.wantItDic valueForKey:@"image_url"];
	NSURL *url = [NSURL URLWithString:urlString];
	self.imageURL = url;
			
	self.wantItDic = appDelegate.wantItDic;
	
	myImageView.x = 42;
	myImageView.y = 37.5;
	[self.myImageView loadImageFromURL:self.imageURL];
	
//	reviewsButton = [[UIBarButtonItem alloc] initWithTitle:@"Reviews" style:UIBarButtonItemStyleBordered target:self action:@selector(reviewsButtonClicked:)];
//	[self.navigationItem setRightBarButtonItem:reviewsButton];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(have_deal:) name:@"have_deal" object:nil];	
	
	
	[nc addObserver:self selector:@selector(handle_have_deal_loaded:) name:@"have_deal_loaded" object:nil]; 
	[nc addObserver:self selector:@selector(handleError:) name:@"update_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"wantIt_data_Parser_Error" object:nil];

	
	elementStack1 = [[NSMutableArray alloc] initWithObjects:@"message",@"errorMessage",nil];
	wantItXmlParser = [[WantItXmlParser alloc] initWithElementStack:elementStack1];
	
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
	
	[restaurantNameLabel setText:[wantItDic valueForKey:@"business_name"]];
	[restaurantLocationLabel setText:[wantItDic valueForKey:@"location_rest_address"]];
	[dealNameLabel setText:[wantItDic valueForKey:@"deal_name"]];
	[creditValueLabel setText:[NSString stringWithFormat:@"$%@",[wantItDic valueForKey:@"deal_credit_value"]]];
	[cuisineTypeIdLabel setText:[wantItDic valueForKey:@"cuisine_type_id"]];
	[dealDescriptionLabel setText:[wantItDic valueForKey:@"deal_description"]];
	[dealRestriction setText:[wantItDic valueForKey:@"rest_deal_restrictions"]];

	
	resultDateString = [[NSString alloc] init];
	
	
	NSString *startDateString = [NSString stringWithFormat:@"%@ %@:00",[wantItDic valueForKey:@"rest_deal_start_date"],[wantItDic valueForKey:@"available_start_time"]];
	NSString *endDateString = [NSString stringWithFormat:@"%@ %@:00",[wantItDic valueForKey:@"rest_deal_end_date"],[wantItDic valueForKey:@"available_end_time"]];

	//******************************************************//
	//					Geting Dates						//
	//******************************************************//
	df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	resultDate = [[NSDateFormatter alloc] init];
	[resultDate setDateFormat :@"EEE, MMM dd yyyy"];
	
	NSString *weakDayString = [wantItDic valueForKey:@"available_week_days"];
	
	NSArray *myArray = [weakDayString componentsSeparatedByString:@","];
	
	resultArray = [[NSMutableArray alloc] init];
	
	NSDateFormatter *weakDay = [[NSDateFormatter alloc] init];
	[weakDay setDateFormat:@"EEE"];
	
	
	
	NSDate *startDate = [df dateFromString:startDateString];
	NSDate *endDate = [df dateFromString:endDateString];
	
	NSDate * now = [NSDate date];
	
	NSDateFormatter *nowDF = [[NSDateFormatter alloc] init];
	[nowDF setDateFormat:@"yyy-MM-dd"];
	
	NSString *nowString = [NSString stringWithFormat:@"%@ %@:00",[nowDF stringFromDate:now],[wantItDic valueForKey:@"available_end_time"]];
	[nowDF release];
	now = [df dateFromString:nowString];
	
	

	switch ([now compare:startDate]){
		case NSOrderedAscending:
			//startDate = startDate;
		
			break;
		case NSOrderedSame:
			startDate = now;
			break;
		case NSOrderedDescending:
			startDate = now;
			
			break;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSDayCalendarUnit;
	NSDateComponents *components = [gregorian components:unitFlags
												fromDate:startDate
												  toDate:endDate options:0];
	int days = [components day];
	
	[gregorian release];
//	if (days == 0) {
//		[resultArray addObject:[resultDate stringFromDate:startDate]];
//	}
//	else {
//		days +=1;
//
//	}
	days +=1;

	for (int i = 0; i < days; i++) {
		
		for (int i = 0; i < [myArray count]; i++) {
			if ([[weakDay stringFromDate:startDate] isEqualToString:[myArray objectAtIndex:i]]) {
				[resultArray addObject:[resultDate stringFromDate:startDate]];
			}
		}
		
		NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:startDate];
		[comp setDay:[comp day] +1];
		[comp setHour: 12];
		[comp setMinute: 00];
		startDate = [[NSCalendar currentCalendar] dateFromComponents:comp];
	}
	
	for (int i = 0; i < [resultArray count]; i++) {

	}
	[weakDay release];
	
	
	
	if ([resultArray count] >0) {
		resultDateString = [resultArray objectAtIndex:0];
		[dateAndTimeLabel setText:[NSString stringWithFormat:@"%@, %@ to %@",[resultArray objectAtIndex:0],[wantItDic valueForKey:@"available_start_time"],[wantItDic valueForKey:@"available_end_time"]]];
	}
	/*
	datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 216.0)];
	[datePicker setDelegate:self];
	[datePicker setDataSource:self];
	*/
	

	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.isGoBackToplaces) {
		[self.navigationController popViewControllerAnimated:NO];
	}
	else {
		if (appDelegate.isFromSearch) {
			
			UIImage *shuffleButtonDisabledImage = [UIImage imageNamed:@"back_button.png"];
            UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [shuffleButton setImage:shuffleButtonDisabledImage forState:UIControlStateNormal];
            
            shuffleButton.frame = CGRectMake(0, 0, shuffleButtonDisabledImage.size.width, shuffleButtonDisabledImage.size.height);
            [shuffleButton addTarget:self action:@selector(gotoSearch) forControlEvents:UIControlEventTouchUpInside]; 
            UIBarButtonItem *shuffleBarItem = [[UIBarButtonItem alloc]	initWithCustomView:shuffleButton];
            
            self.navigationItem.leftBarButtonItem = shuffleBarItem;
			
			NSString *urlString = [appDelegate.wantItDic valueForKey:@"image_url"];
			NSURL *url = [NSURL URLWithString:urlString];
			self.imageURL = url;
			
			self.wantItDic = appDelegate.wantItDic;
			
			
			
			myImageView.x = 42;
			myImageView.y = 37.5;
			[self.myImageView loadImageFromURL:self.imageURL];
			[restaurantNameLabel setText:[wantItDic valueForKey:@"business_name"]];
			[restaurantLocationLabel setText:[wantItDic valueForKey:@"location_rest_address"]];
			[dealNameLabel setText:[wantItDic valueForKey:@"deal_name"]];
			[creditValueLabel setText:[NSString stringWithFormat:@"$%@",[wantItDic valueForKey:@"deal_credit_value"]]];
			[cuisineTypeIdLabel setText:[wantItDic valueForKey:@"cuisine_type_id"]];
			[dealDescriptionLabel setText:[wantItDic valueForKey:@"deal_description"]];
			[dealRestriction setText:[wantItDic valueForKey:@"rest_deal_restrictions"]];
			
			
			
			NSString *startDateString = [NSString stringWithFormat:@"%@ %@:00",[wantItDic valueForKey:@"rest_deal_start_date"],[wantItDic valueForKey:@"available_start_time"]];
			NSString *endDateString = [NSString stringWithFormat:@"%@ %@:00",[wantItDic valueForKey:@"rest_deal_end_date"],[wantItDic valueForKey:@"available_end_time"]];
			
			//******************************************************//
			//					Geting Dates						//
			//******************************************************//
	//		df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			
			NSString *weakDayString = [wantItDic valueForKey:@"available_week_days"];
			
			NSArray *myArray = [weakDayString componentsSeparatedByString:@","];
			
			
			NSDateFormatter *weakDay = [[NSDateFormatter alloc] init];
			[weakDay setDateFormat:@"EEE"];
			
			
			
			NSDate *startDate = [df dateFromString:startDateString];
			NSDate *endDate = [df dateFromString:endDateString];
			
			NSDate * now = [NSDate date];
			
			NSDateFormatter *nowDF = [[NSDateFormatter alloc] init];
			[nowDF setDateFormat:@"yyy-MM-dd"];
			
			NSString *nowString = [NSString stringWithFormat:@"%@ %@:00",[nowDF stringFromDate:now],[wantItDic valueForKey:@"available_end_time"]];
			[nowDF release];
			now = [df dateFromString:nowString];
			
			switch ([now compare:startDate]){
				case NSOrderedAscending:
					//startDate = startDate;
					
					break;
				case NSOrderedSame:
					startDate = now;
					break;
				case NSOrderedDescending:
					startDate = now;
				
					break;
			}
			
			NSCalendar *gregorian = [[NSCalendar alloc]
									 initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned int unitFlags = NSDayCalendarUnit;
			NSDateComponents *components = [gregorian components:unitFlags
														fromDate:startDate
														  toDate:endDate options:0];
			int days = [components day];
			
			[gregorian release];
			
			days +=1;
			
			
			if ([resultArray count] >0 ) {
				[resultArray removeAllObjects];
			}
			for (int i = 0; i < days; i++) {
				
				for (int i = 0; i < [myArray count]; i++) {
					if ([[weakDay stringFromDate:startDate] isEqualToString:[myArray objectAtIndex:i]]) {
						[resultArray addObject:[resultDate stringFromDate:startDate]];
					}
				}
				
				NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:startDate];
				[comp setDay:[comp day] +1];
				[comp setHour: 12];
				[comp setMinute: 00];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:comp];
			}
			
			for (int i = 0; i < [resultArray count]; i++) {
			}
			[weakDay release];
			
			
			
			if ([resultArray count]>0) {
				
				resultDateString = [resultArray objectAtIndex:0];
				[dateAndTimeLabel setText:[NSString stringWithFormat:@"%@, %@ to %@",[resultArray objectAtIndex:0],[wantItDic valueForKey:@"available_start_time"],[wantItDic valueForKey:@"available_end_time"]]];
			}
			
			
		}
		appDelegate.isFromSearch = NO;
		appDelegate.wantToGoBack = NO;
		
		/*
		 
		 [self.datePicker reloadAllComponents];
		 
		 */
	}
}

-(void)gotoSearch{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.objTabBarController setSelectedIndex:2];
}

//-(void)reviewsButtonClicked:(id)sender{
//	ReviewsViewController *reviewsViewController = [[ReviewsViewController alloc] init];
//	//reviewsViewController.dealID = [self.wantItDic valueForKey:@"id"];
//	reviewsViewController.dealDic = self.wantItDic;
//	[self.navigationController pushViewController:reviewsViewController animated:YES];
//	[reviewsViewController release];
//}


-(IBAction)fixDealButtonClicked:(id)sender{
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add referral Email ID, If any?" message:@"Add referral Email ID, If any"
//												   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];  
//	referalEmailId = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
//	[referalEmailId setBackgroundColor:[UIColor whiteColor]];
//	[referalEmailId becomeFirstResponder];
//	[referalEmailId setAutocorrectionType:YES];
//	[referalEmailId setPlaceholder:@"Referral Email ID"];
//	[referalEmailId setKeyboardType:UIKeyboardTypeEmailAddress];
//	[alert addSubview:referalEmailId];
//	alert.tag = 999;
//	
//	[alert show];
//	[alert release];
	
//	[referalEmailId release];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"have_deal" object:self userInfo:nil];
	
}

-(void)have_deal:(NSNotification *)pNotification{
	
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	
	//NSString *emailId = [settingsDictionary valueForKey:@"username"];
	//NSString *password = [settingsDictionary valueForKey:@"password"];
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *emailId = [appDelegate.settingsDict valueForKey:@"username"];
    NSString *password = [appDelegate.settingsDict valueForKey:@"password"];
	
//	if ([emailId length]>0 && [password length]>0) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY-MM-dd"];//2011/11/21,00:00
		
		//NSDate *date = [resultDate dateFromString:resultDateString];
    //NSString *str = [wantItDic valueForKey:@"rest_deal_end_date"];
       // NSDate *date = [resultDate dateFromString:[wantItDic valueForKey:@"rest_deal_end_date"]];
    
       // NSDate *date = [formatter dateFromString:[wantItDic valueForKey:@"rest_deal_end_date"]];
		
		//NSString *dateString1 = [formatter stringFromDate:date];
		
		NSString *dateString = [NSString stringWithFormat:@"%@ %@:00",resultDateString,[wantItDic valueForKey:@"available_start_time"]];
		
		[formatter release];
		
		NSDateFormatter *nowDateFormater = [[NSDateFormatter alloc] init];
		[nowDateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSString *nowDateString = [nowDateFormater stringFromDate:[NSDate date]];
		[nowDateFormater release];
		
		
		NSString *serviceURL = [NSString stringWithFormat:@"%@/deals/insertdeal?emailId=%@&password=%@&dealId=%@&timestamp=%@&refEmailId=&orderedtimestamp=%@",SERVER_URL,emailId,password,[wantItDic valueForKey:@"id"],dateString,nowDateString];//2011-03-02 05:22:55
    
    NSLog(@"%@",serviceURL);
    
        [wantItXmlParser loadFromURL:serviceURL];
		//[wantItXmlParser loadFromBundle:serviceURL];
//	}
//	else {
//		
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please Provide Email Id And Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
//		[alert setTag:111];
//		[alert show];
//		[alert release];
//		
//	}

	
	
	[self showActivityIndicatorView];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (buttonIndex == 1 && alertView.tag==111) {
		appDelegate.isFromWantIt = YES;
		[appDelegate.objTabBarController setSelectedIndex:3];
	}
	else if(buttonIndex == 0 && alertView.tag == 222){
		appDelegate.isWantToGoBackInMyDeals = YES;
		[appDelegate.objTabBarController setSelectedIndex:0];
	}

//	else if(buttonIndex == 0 && alertView.tag==999){
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"have_deal" object:self userInfo:nil];
//	}
}



- (void)handle_have_deal_loaded:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
	NSString *result = [[note userInfo] objectForKey:@"message"];	
	if ([result isEqualToString:@"Your reservation is complete"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:222];
		[alert show];
		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert setTag:333];
		[alert show];
		[alert release];
	}

	
//	[self stopActivityIndicatorView];
//	[self account_for_empty_results];
	
	
}

- (void)account_for_empty_results{
	
}
-(void)handle_network_timeout:(NSNotification *)note
{
	[self stopActivityIndicatorView];
}

- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
	
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(IBAction)shareItButtonClicked:(id)sender{
	ShareItViewController *shareItViewController = [[ShareItViewController alloc] init];
	shareItViewController.dealDic = self.wantItDic;
	if ([resultArray count] >0) {
		shareItViewController.availableDate = [resultArray objectAtIndex:0];
	}
	[self.navigationController pushViewController:shareItViewController animated:YES];
	[shareItViewController release];
}

-(IBAction)mapButtonClicked:(id)sender{
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isWantToPopInMap = YES;
	
	MapViewController *mapObj = [[MapViewController alloc] init];
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[array addObject:wantItDic];
	mapObj.placesMapArray = array;
	[array release];
	[self.navigationController pushViewController:mapObj animated:YES];
	[mapObj release];
}

- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initCentered];
		[activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 324)];
		[self.view addSubview:activityIndicatorView];
		[self.tabBarController.tabBar setUserInteractionEnabled:NO];
		self.navigationItem.hidesBackButton = YES;
		[reviewsButton setEnabled:NO];
	}
}

-(void)stopActivityIndicatorView{
	[self.tabBarController.tabBar setUserInteractionEnabled:YES];
	self.navigationItem.hidesBackButton = NO;
	[reviewsButton setEnabled:YES];
	[activityIndicatorView removeActivityIndicator];

}
/*
-(IBAction)textFieldReturnClicked{
	[emailTextField resignFirstResponder];
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	// Get the position of the UITextField rectangle
	// If its bottom edge is 250 or greater, then move it up
	// FYI - the portrait keyboard is 216 pixels in height
	
	// Make a CGRect so we can get the textField dimensions and position
	// The following statement gets the rectangle
	CGRect textViewRect = [self.view.window convertRect:textField.bounds fromView:textField];
	// Find out what the bottom edge value is
	CGFloat bottomEdge = textViewRect.origin.y + textViewRect.size.height;
	
	// If the bottom edge is 250 or more, we want to shift the view up
	// We chose 250 here instead of 264, so that we would have some visual buffer space
	if (bottomEdge >= 250) {
		
		// Make a CGRect for the view (which should be positioned at 0,0 and be 320px wide and 480px tall)
		CGRect viewFrame = self.view.frame;
		
		// Determine the amount of the shift
		self.shiftForKeyboard = bottomEdge - 250.0f;
		
		// Adjust the origin for the viewFrame CGRect
		viewFrame.origin.y -= self.shiftForKeyboard;
		
		// The following animation setup just makes it look nice when shifting
		// We don't really need the animation code, but we'll leave it in here
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3];
		
		// Apply the new shifted vewFrame to the view
		[self.view setFrame:viewFrame];
		
		// More animation code
		[UIView commitAnimations];
		
	} else {
		// No view shifting required; set the value accordingly
		self.shiftForKeyboard = 0.0f;
	}
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	
	// Resign first responder
	[textField resignFirstResponder];
	
	// Make a CGRect for the view (which should be positioned at 0,0 and be 320px wide and 480px tall)
	CGRect viewFrame = self.view.frame;
	
	// Adjust the origin back for the viewFrame CGRect
	viewFrame.origin.y += self.shiftForKeyboard;
	// Set the shift value back to zero
	self.shiftForKeyboard = 0.0f;
	
	// As above, the following animation setup just makes it look nice when shifting
	// Again, we don't really need the animation code, but we'll leave it in here
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	
	// Apply the new shifted vewFrame to the view
	[self.view setFrame:viewFrame];
	
	// More animation code
	[UIView commitAnimations];
}
/*

#pragma mark -
#pragma mark Date Picker  Methods


-(IBAction)changeDateButtonClicked:(id)sender{
	dateActionSheet = [[UIActionSheet alloc] initWithTitle:@"From Date"
												  delegate:self
										 cancelButtonTitle:nil
									destructiveButtonTitle:nil
										 otherButtonTitles:nil];
	
	[datePicker setShowsSelectionIndicator:YES];
	
	UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerDateToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClick:)];
	[barItems addObject:doneBtn];
	[doneBtn release];
	[pickerDateToolbar setItems:barItems animated:YES];
	[barItems release];
	[flexSpace release];
	[dateActionSheet showInView:self.view];
	[dateActionSheet addSubview:pickerDateToolbar];
	[dateActionSheet addSubview:datePicker];
	[dateActionSheet setBounds:CGRectMake(0,0,320, 464)];
	[pickerDateToolbar release];
	
}

-(void)datePickerDoneClick:(id)sender{
	//	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	//	[formatter setDateFormat:WRITING_DATE_FORMAT];//2011/11/21,00:00
	
	//	NSString *dateString = [formatter stringFromDate:choosen];
	//	[formatter release];
	[dateAndTimeLabel setText:[NSString stringWithFormat:@"%@, %@ to %@",resultDateString,[wantItDic valueForKey:@"available_start_time"],[wantItDic valueForKey:@"available_end_time"]]];
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [resultArray count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	return 250;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [resultArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	resultDateString = [resultArray objectAtIndex:row];
}
*/

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
	//[elementStack1 release];
	[df release];
	[emailTextField release];
	[reviewsButton release];
	[activityIndicatorView release];
	[imageURL release];
	[myImageView release];
	[resultDateString release];
	[resultDate release];
	[dealDescriptionLabel release];
	[dealRestriction release];
	[dateAndTimeLabel release];
	[restaurantNameLabel release];
	[restaurantLocationLabel release];
	[dealNameLabel release];
	[creditValueLabel release];
	[cuisineTypeIdLabel release];
	[dealTimeButton release];
	[wantItDic release];
	[reviewsArray release];
	[datePicker release];
	[wantItXmlParser release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"have_deal" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"have_deal_loaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"update_error_occured" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_timeout" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"wantIt_data_Parser_Error" object:nil];

    [super dealloc];
}


@end
