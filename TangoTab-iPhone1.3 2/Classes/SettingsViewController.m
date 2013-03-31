///
//  SettingsViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "TangoTabAppDelegate.h"
#import "defines.h"
#import "SignUpViewController.h"

#define kNameValueTag    2

@implementation SettingsViewController
@synthesize settingsTableView,sharingOptionsArray,checkInOptionsArray,loginArray;
@synthesize autoCheckInSwitch,pushNotificationSwitch,facebookSwitch,twitterSwitch,userNameTextField,passwordTextField,searchingRadiusTextField;
@synthesize doneButton,elementStack1;
@synthesize userValidationParser;
@synthesize activityIndicatorView;
@synthesize logOutButton;
@synthesize settingsDict;
@synthesize delegate;
@synthesize searchingDistanceButton;
@synthesize searchingScopeArray;
@synthesize searchingScopeDisplayArray;
@synthesize dropDownView;
//Gopal
@synthesize checked;
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
	[nc addObserver:self selector:@selector(user_validation:) name:@"user_validation" object:nil];	
		
	[nc addObserver:self selector:@selector(valid_user:) name:@"valid_user" object:nil]; 
	[nc addObserver:self selector:@selector(in_valid_user:) name:@"in_valid_user" object:nil];
	[nc addObserver:self selector:@selector(handleError:) name:@"user_validation_error_occured" object:nil];
	[nc addObserver:self selector:@selector(dataParserError:) name:@"userValidation_data_Parser_Error" object:nil];
	
	elementStack1 = [[NSMutableArray alloc] initWithObjects:@"user_details",@"first_name",@"last_name",@"zip_code",@"mobile_phone",@"address",@"message",@"errorMessage",nil];
	userValidationParser = [[UserValidationParser alloc] initWithElementStack:elementStack1];
	
	NSNotificationCenter *network_timeout __attribute__((unused)) = [NSNotificationCenter defaultCenter];
	[network_timeout addObserver:self selector:@selector(handle_network_timeout:) name:@"network_timeout" object:nil];
	
	self.title = @"Settings";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];

	loginArray = [[NSMutableArray alloc] init];
	[loginArray addObject:@"Email"];
	[loginArray addObject:@"Password"];
    [loginArray addObject:@"Keep me signed-in"];
	
	
	sharingOptionsArray = [[NSMutableArray alloc] init];
	[sharingOptionsArray addObject:@"Push Notifications"];
	[sharingOptionsArray addObject:@"Share With Facebook"];
	[sharingOptionsArray addObject:@"Share With Twitter"];
	
	checkInOptionsArray = [[NSMutableArray alloc] init];
	[checkInOptionsArray addObject:@"Auto Checkins"];
	
	doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
	[self.navigationItem setRightBarButtonItem:doneButton];

	logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonClicked:)];
	[self.navigationItem setLeftBarButtonItem:logOutButton];
	self.settingsTableView.allowsSelection = NO;
	
	userNameTextField = [[UITextField  alloc ] initWithFrame: CGRectMake(120, 8, 180, 31) ];
	[userNameTextField setPlaceholder:@"Enter Email"];
	[userNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[userNameTextField setBorderStyle:UITextBorderStyleBezel];
	[userNameTextField setSecureTextEntry:NO];
	[userNameTextField setKeyboardType:UIKeyboardTypeEmailAddress];
	[userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[userNameTextField setReturnKeyType:UIReturnKeyNext];
	[userNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[userNameTextField addTarget:self action:@selector(userNameTextFieldNextClickedClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	passwordTextField = [[ UITextField alloc ] initWithFrame: CGRectMake(120, 8, 180, 31) ];
	[passwordTextField setPlaceholder:@"Enter Password"];
	[passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[passwordTextField setBorderStyle:UITextBorderStyleBezel];
	[passwordTextField setSecureTextEntry:YES];
	[passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[passwordTextField setReturnKeyType:UIReturnKeyGo];
	[passwordTextField addTarget:self action:@selector(passwordTextFieldNextClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    searchingRadiusTextField = [ [ UITextField alloc ] initWithFrame: CGRectMake(120, 8, 180, 31) ];
        
//    remberButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    remberButton.frame = CGRectMake(190, 8, 30, 30);
//    remberButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    remberButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [remberButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown];
//    [remberButton setBackgroundImage:[UIImage imageNamed:@"notselected.png"] forState:UIControlStateNormal];
    rememberSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(200, 8, 79, 21)];
    [rememberSwitch setOn:YES];
    [rememberSwitch addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventValueChanged];
    checked=YES;
    
    searchingRadiusTextField.text = [NSString stringWithFormat:@"%.0f", [[settingsDict objectForKey:@"searchingradius"] doubleValue]];
	[searchingRadiusTextField setBorderStyle:UITextBorderStyleBezel];
    [searchingRadiusTextField setReturnKeyType:UIReturnKeyDone];
    [userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [searchingRadiusTextField setKeyboardType:UIKeyboardTypeNumberPad];
	[searchingRadiusTextField addTarget:self action:@selector(searchingRadiusTextFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];

    pushNotificationSwitch = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
	pushNotificationSwitch.on = YES;
	[pushNotificationSwitch addTarget:self action:@selector(pushNotificationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	autoCheckInSwitch = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
	autoCheckInSwitch.on = YES;
	[autoCheckInSwitch addTarget:self action:@selector(autoCheckInSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];

	facebookSwitch = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
	facebookSwitch.on = YES;
	[facebookSwitch addTarget:self action:@selector(facebookSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	twitterSwitch = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
	twitterSwitch.on = YES;
	[twitterSwitch addTarget:self action:@selector(twitterSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];	
	
    searchingScopeDisplayArray = [[NSArray alloc] initWithObjects:@"5 miles",@"10 miles",@"20 miles",@"50 miles", @"50+ miles", nil];
    searchingScopeArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:50], [NSNumber numberWithInt:1000], nil];
    searchingDistanceButton = [[UIButton alloc] initWithFrame:CGRectMake(120, 8, 180, 31)]; 
	dropDownView = [[DropDownView alloc] initWithArrayData:searchingScopeDisplayArray cellHeight:30 heightTableView:200 paddingTop:-8 paddingLeft:-50 paddingRight:-10 refView:searchingDistanceButton animation:BLENDIN openAnimationDuration:0.5 closeAnimationDuration:0.5];
    //dropDownView = [[DropDownView alloc] initWithArrayData:searchingScopeArray cellHeight:30 heightTableView:200 paddingTop:-8 paddingLeft:-5 paddingRight:-10 refView:searchingDistanceButton animation:BLENDIN openAnimationDuration:2 closeAnimationDuration:2];
	dropDownView.delegate = self;
    
    NSUInteger idx = 0;
    
    if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<10.0) {
        idx = 0;
    }
    else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<11.0) {
        idx = 1;
    }
    else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<21.0) {
        idx = 2;
    }
    else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<51.0) {
        idx = 3;
    }
    else {
        idx = 4;
    }
    
	[searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:idx] forState:UIControlStateNormal];
    [searchingDistanceButton setHidden:NO];
    //[searchingDistanceButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    
    searchingDistanceButton.backgroundColor = [UIColor clearColor];
    searchingDistanceButton.imageView.image = [UIImage imageNamed:@"button_back.png"];
    
    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
    [searchingDistanceButton addTarget:self action:@selector(searchingScopeChanged:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkAction:(id)sender
{
    UISwitch *switc=(UISwitch*)sender;
    if(switc.on==YES)
    {
        self.checked=YES;
    }
    else 
    {
        self.checked=NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	if (! appDelegate.isUserLogedIn) {
		self.title = @"Login";
		[doneButton setTitle:@"Login"];
		[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
		appDelegate.isUserLogedIn = NO;
		[self.settingsTableView setScrollEnabled:YES];
		self.navigationItem.leftBarButtonItem.title = @"Sign up";
		[userNameTextField becomeFirstResponder];
	}
	else {
		[self.settingsTableView setScrollEnabled:YES];

        BOOL autoCheckIn =[[self.settingsDict valueForKey:@"autoCheckIn"] boolValue];
		if (autoCheckIn) {
			[autoCheckInSwitch setOn:YES];
		}
		else {
			[autoCheckInSwitch setOn:NO];
			
		}

        BOOL pushNotification =[[self.settingsDict valueForKey:@"pushNotification"] boolValue];
		if (pushNotification) {
			[pushNotificationSwitch setOn:YES];
		}
		else {
			[pushNotificationSwitch setOn:NO];
			
		}

        BOOL facebook =[[self.settingsDict valueForKey:@"facebook"] boolValue];
		if (facebook) {
			[facebookSwitch setOn:YES];
		}
		else {
			[facebookSwitch setOn:NO];
			
		}

        BOOL twitter =[[self.settingsDict valueForKey:@"twitter"] boolValue];
		if (twitter) {
			[twitterSwitch setOn:YES];
		}
		else {
			[twitterSwitch setOn:NO];
			
		}
	}

	[userNameTextField removeFromSuperview];
	[passwordTextField removeFromSuperview];
	
	[self.settingsTableView reloadData];
}


-(void)user_validation:(NSNotification *)pNotification{
	
	[self showActivityIndicatorView];

    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *passwordStringEncoded = [[NSString alloc] init];
    NSString *passwordString= [[NSString alloc] init];;
    NSString *userName= [[NSString alloc] init];;
    NSData* aData;
    if ([appDelegate.prefs valueForKey:@"username"]) {
        passwordStringEncoded   = [appDelegate.prefs valueForKey:@"password"];
        userName   = [appDelegate.prefs valueForKey:@"username"];
        
    } 
    else {
        passwordString = [passwordTextField text];
        aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
        passwordStringEncoded = [aData base64Encoding]; 
        userName = [userNameTextField text];
    }
    
    NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",SERVER_URL,userName,passwordStringEncoded];	
    [userValidationParser loadFromURL:serviceURL];
}


-(void)handle_network_timeout:(id)sender{
	[self stopActivityIndicatorView];
}


- (void)handleError:(NSNotification *)note
{	
	[self stopActivityIndicatorView];
}

- (void)valid_user:(NSNotification *)note
{	
	[self stopActivityIndicatorView];

	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appDelegate.userInfoDic = [note userInfo];	
	

	
	[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:YES];
	appDelegate.isUserLogedIn = YES;
	self.navigationItem.leftBarButtonItem.title = @"Sign Out";
	self.title = @"Settings";
	[doneButton setTitle:@"Update"];
	
	[self setLoginCredentials];
	
}

- (void)in_valid_user:(NSNotification *)note
{	
	[self stopActivityIndicatorView];

	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
	appDelegate.isUserLogedIn = NO;
	self.navigationItem.leftBarButtonItem.title = @"Sign up";
	[doneButton setTitle:@"Login"];
	self.title = @"Login";
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[[note userInfo] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
}

- (void)account_for_empty_results
{

}

-(void)logOutButtonClicked:(id)sender{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (self.navigationItem.leftBarButtonItem.title == @"Sign up") {
		[userNameTextField setText:@""];
		[passwordTextField setText:@""];
		SignUpViewController *signUpObj = [[SignUpViewController alloc] init];
		signUpObj.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:signUpObj animated:YES];
		[signUpObj release];
	}
	else {
        [rememberSwitch setHidden:NO];
		[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
		appDelegate.isUserLogedIn = NO;
		[self.settingsTableView setScrollEnabled:YES];
		
		self.title = @"Login";
		[doneButton setTitle:@"Login"];
		self.navigationItem.leftBarButtonItem.title = @"Sign up";
		
		//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		//NSMutableDictionary *settingsDictionary;
		//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];
		
		//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
		
		
		[self.settingsDict setValue:@"" forKey:@"username"];
		[self.settingsDict setValue:@"" forKey:@"password"];
        [self.settingsDict setValue:[NSNumber numberWithBool:NO] forKey:@"userloggedin"];
        appDelegate.isUserLogedIn = NO;

        if (self.delegate && [self.delegate respondsToSelector:@selector(saveObject:)]) {
            [self.delegate saveObject:self.settingsDict];
        }
		//[settingsDictionary writeToFile:mydictpath atomically:YES];
        
        [appDelegate.prefs setValue:nil forKey:@"username"];
        [appDelegate.prefs setValue:nil forKey:@"password"];
        [appDelegate.prefs synchronize];
        [remberButton setBackgroundImage:[UIImage imageNamed:@"notselected.png"] forState:UIControlStateNormal];
        checked = NO;
        


		[passwordTextField setText:@""];
		[userNameTextField setText:@""];
		
		[autoCheckInSwitch removeFromSuperview];
		[pushNotificationSwitch removeFromSuperview];
		[facebookSwitch removeFromSuperview];
		[twitterSwitch removeFromSuperview];
		[self.settingsTableView reloadData];
		[userNameTextField becomeFirstResponder];
	}

}


#pragma mark -
#pragma mark tableView methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (appDelegate.isUserLogedIn) {
		return 3; //2;
	}
	else {
		return 1;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isUserLogedIn) {
		switch (section) {
            case 0:
                return 1;
                break;
			case(1):
				return [checkInOptionsArray count];
				break;
			case(2):
				return [sharingOptionsArray count];
				break;
		}
	}
	else {
		return [loginArray count];

	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isUserLogedIn) {
		switch (section) {
			case 0:
                return @"Searching Scope Options";
                break;
			case(1):
				return @"Checkin Options";
				break;
			case(2):
				return @"Sharing Options";
				break;
		}
	}
	else {
		return @" ";
	}

	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setSelected:NO];
        
    }
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (appDelegate.isUserLogedIn) {
        if (indexPath.section==0) {
            //cell.textLabel.text = @"Searching Radius for Deals";
            cell.textLabel.text = @"Distance to Deals";
            
            NSUInteger idx = 0;
            
            if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<10.0) {
                idx = 0;
            }
            else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<11.0) {
                idx = 1;
            }
            else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<21.0) {
                idx = 2;
            }
            else if ([[settingsDict objectForKey:@"searchingradius"] doubleValue]<51.0) {
                idx = 3;
            }
            else {
                idx = 4;
            }
   
            
            [searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:idx] forState:UIControlStateNormal];
            searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
            
            [cell addSubview: searchingDistanceButton];
            //[cell addSubview:dropDownView.view];
            [self.view addSubview:dropDownView.view];
        }
		else if (indexPath.section == 1) {
			cell.textLabel.text = [checkInOptionsArray objectAtIndex:indexPath.row];
			
			[cell addSubview: autoCheckInSwitch ];
		}
		else if(indexPath.section == 2) {
			
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = [sharingOptionsArray objectAtIndex:indexPath.row];
					
					[cell addSubview: pushNotificationSwitch ];
					break;
				case 1:
					cell.textLabel.text = [sharingOptionsArray objectAtIndex:indexPath.row];
					
					[cell addSubview: facebookSwitch ];
					break;
				case 2:
					cell.textLabel.text = [sharingOptionsArray objectAtIndex:indexPath.row];
					[cell addSubview: twitterSwitch ];
                    [rememberSwitch setHidden:YES];
					break;
					
				default:
					break;
			}
		}
        
	}
	else {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [loginArray objectAtIndex:indexPath.row];
				
				[cell addSubview: userNameTextField ];
				break;
			case 1:
				cell.textLabel.text = [loginArray objectAtIndex:indexPath.row];
				
				[cell addSubview: passwordTextField ];
				break;
                
            case 2:
				cell.textLabel.text = [loginArray objectAtIndex:indexPath.row];
				[cell addSubview:rememberSwitch];
				break;
				
			default:
				break;
		}
		
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
}


-(void)autoCheckInSwitchValueChanged:(id)sender{
	
}
-(void)pushNotificationSwitchValueChanged:(id)sender{
	

}
-(void)facebookSwitchValueChanged:(id)sender{


}
-(void)twitterSwitchValueChanged:(id)sender{
	

}

#pragma mark -
#pragma mark DropDownViewDelegate
-(void)dropDownCellSelected:(NSInteger)returnIndex
{
    [searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:returnIndex] forState:UIControlStateNormal];
    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
    
    //[self searchingRadiusTextFieldDone];
    //NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    //[f setNumberStyle:NSNumberFormatterDecimalStyle];
    //NSNumber *num = [f numberFromString:searchingRadiusTextField.text];
    //[f release];
        
    [self.settingsDict setValue:[searchingScopeArray objectAtIndex:returnIndex] forKey:@"searchingradius"];
}

-(void)searchingScopeChanged:(id)sender{

    [dropDownView openAnimation];
}


-(void)doneButtonClicked:(id)sender{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isUserLogedIn) {
		[self setValuesToPlistFile];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"User settings have been updated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {
		if ([userNameTextField.text length] == 0 || [passwordTextField.text length] == 0) {
			[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
			appDelegate.isUserLogedIn = NO;
			self.navigationItem.leftBarButtonItem.title = @"Sign up";
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide valid Login information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else {
			[userNameTextField resignFirstResponder];
			[passwordTextField resignFirstResponder];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"user_validation" object:self userInfo:nil];
			
			[appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
			//self.navigationItem.leftBarButtonItem.title = @"Logout";
			appDelegate.isUserLogedIn = NO;
		}
	}
	
	
}

-(void)setLoginCredentials{
    
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	NSString *passwordString = [passwordTextField text];
	NSData* aData = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
	NSString *passwordStringEncoded = [aData base64Encoding]; 
    
    [self.settingsDict setValue:[userNameTextField text] forKey:@"username"];
    [self.settingsDict setValue:passwordStringEncoded forKey:@"password"];
    [self.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"userloggedin"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveObject:)]) {
        [self.delegate saveObject:self.settingsDict];
    }
    
 
    
    if (checked) {
        [appDelegate.prefs setObject:[userNameTextField text] forKey:@"username"];
        [appDelegate.prefs setValue:passwordStringEncoded forKey:@"password"];
        [appDelegate.prefs synchronize];
    }
    
    appDelegate.isUserLogedIn = YES;
	[appDelegate.objTabBarController setSelectedIndex:2];

}

-(void)setValuesToPlistFile{
    
    if (autoCheckInSwitch.on) {
		[self.settingsDict setValue:[NSNumber numberWithBool:1] forKey:@"autoCheckIn"];
	}
	else {
		[self.settingsDict setValue:[NSNumber numberWithBool:0] forKey:@"autoCheckIn"];
	}
	
	
	if (pushNotificationSwitch.on) {
		[self.settingsDict setValue:[NSNumber numberWithBool:1] forKey:@"pushNotification"];
	}
	else {
		[self.settingsDict setValue:[NSNumber numberWithBool:0] forKey:@"pushNotification"];
	}
	
	if (facebookSwitch.on) {
		[self.settingsDict setValue:[NSNumber numberWithBool:1] forKey:@"facebook"];
	}
	else {
		[self.settingsDict setValue:[NSNumber numberWithBool:0] forKey:@"facebook"];
	}
	
	if (twitterSwitch.on) {
		[self.settingsDict setValue:[NSNumber numberWithBool:1] forKey:@"twitter"];
	}
	else {
		[self.settingsDict setValue:[NSNumber numberWithBool:0] forKey:@"twitter"];
	}
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveObject:)]) {
     

        [self.delegate saveObject:self.settingsDict];
    }
    
//	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
//	if (appDelegate.isFromWantIt) {
//		appDelegate.isFromWantIt = NO;
//		[appDelegate.objTabBarController setSelectedIndex:1];
//	}
//	else {
//		TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
//		[appDelegate.objTabBarController setSelectedIndex:1];
//	}
	
}

-(void)dataParserError:(NSNotification *)pNotification{
	[self stopActivityIndicatorView];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Data error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)userNameTextFieldNextClickedClicked:(id)sender
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isFromWantIt = NO;
	
	[passwordTextField becomeFirstResponder];
//	[userNameTextField resignFirstResponder];
//	[passwordTextField resignFirstResponder];
}

-(void)passwordTextFieldNextClicked:(id)sender
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.isFromWantIt = NO;
	
    //[userNameTextField resignFirstResponder];
    [passwordTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"user_validation" object:self userInfo:nil];
    
    [appDelegate.objTabBarController.tabBar setUserInteractionEnabled:NO];
    //self.navigationItem.leftBarButtonItem.title = @"Logout";
    appDelegate.isUserLogedIn = NO;
    
	//[userNameTextField becomeFirstResponder];
}

/*-(void)searchingRadiusTextFieldDone
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *num = [f numberFromString:searchingRadiusTextField.text];
    [f release];
    
    [self.settingsDict setValue:num forKey:@"searchingradius"];
    
    //if (self.delegate && [self.delegate respondsToSelector:@selector(saveObject:)]) {
    //    [self.delegate saveObject:self.settingsDict];
    //}
}*/

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
	//	[activityIndicatorView adjustFrame:CGRectMake(0, 0, 320, 324)];
		[self.view addSubview:activityIndicatorView];
		[doneButton setEnabled:NO];
		[logOutButton setEnabled:NO];
	}
	
}

-(void)stopActivityIndicatorView{	
	[doneButton setEnabled:YES];
	[logOutButton setEnabled:YES];
	[activityIndicatorView removeActivityIndicator];
//	[activityIndicatorView release];
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
	[logOutButton release];
	[activityIndicatorView release];
	[userValidationParser release];
	[elementStack1 release];
	[settingsTableView release];
	[sharingOptionsArray release];
	[checkInOptionsArray release];
	[loginArray release];
	[doneButton release];
	[autoCheckInSwitch release];
	[pushNotificationSwitch release];
	[facebookSwitch release];
	[twitterSwitch release];
	[userNameTextField release];
	[passwordTextField release];
    [settingsDict release];
    [searchingScopeArray release];
    [searchingScopeDisplayArray release];
    [searchingDistanceButton release];
    [dropDownView release];
    
    [super dealloc];
}


@end
