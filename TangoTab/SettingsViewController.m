//
//  SettingsViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "defines.h"

@implementation SettingsViewController
@synthesize settingsTableView;
@synthesize settingsDisArray,settingsAutoArray,settingsPushArray;
@synthesize autoCheckInSwitch,pushNotificationSwitch;
@synthesize searchingDistanceButton,signOut, leftSwipeOne, leftSwipeTwo, rightSwipe;
@synthesize versionLabel,dropDownView,searchingScopeArray,searchingScopeDisplayArray,settingsDetails,sharedDelegate;
@synthesize signoutArray;
@synthesize signin,keychain, activeLogin, appVersion;

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

-(void)handleRightSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
  debug_NSLog(@"Swipe RIGHT received.");
    if (leftSwipeOne && leftSwipeTwo)
    {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:@"Select Server"
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle: nil
                               otherButtonTitles: @"Production", @"Stage", @"QA", @"Development", nil];
        [menu showInView: self.view ];

    }
   
    leftSwipeOne = FALSE;
    leftSwipeTwo = FALSE;
   
    
}

-(void) actionSheet: (UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    if (buttonIndex == 0) // production
    {
        sharedDelegate.activeServerUrl = PRODUCTION_SERVER;
    }
    else
        if (buttonIndex == 1) 
        {
             sharedDelegate.activeServerUrl = STAGE_SERVER;
        }
        else
            if (buttonIndex == 2) 
            {
                 sharedDelegate.activeServerUrl = QA_SERVER;
            }
            else
                if (buttonIndex == 3) 
                {
                    sharedDelegate.activeServerUrl = DEVEL_SERVER;
                }
    
    [[NSUserDefaults standardUserDefaults] setObject:sharedDelegate.activeServerUrl  forKey:@"activeServer"];
    [[NSUserDefaults standardUserDefaults] setObject: nil forKey:@"previousLogin"];   
    [[NSUserDefaults standardUserDefaults] synchronize];

    
     self.navigationBar.topItem.title = [sharedDelegate currentServer:@"Settings"];
     sharedDelegate.isSelectedDisButton = YES;
     sharedDelegate.myOffersUpdate = NO;
     sharedDelegate.updateSearch = YES;
     [sharedDelegate setCurrentDate];
}

-(void)handleLeftSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    debug_NSLog(@"Swipe LEFT received.");
    if (leftSwipeOne == FALSE) {
        leftSwipeOne = TRUE;
        leftSwipeTwo = FALSE;
    }
    else
        leftSwipeTwo = TRUE;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    leftSwipeTwo = FALSE;
    leftSwipeOne = FALSE;
    rightSwipe = FALSE;
    self.settingsTableView.allowsSelection = NO;
     self.navigationController.navigationBarHidden=YES;
    sharedDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];

    settingsDisArray = [[NSArray alloc] initWithObjects:@"Distance to offers", nil];
 
    settingsPushArray = [[NSArray alloc]initWithObjects:@"",nil];
    
    UISwipeGestureRecognizer *mSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeFrom:)];
    
    [mSwipeRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    
    [[self view] addGestureRecognizer:mSwipeRecognizer];
    
    [mSwipeRecognizer release];
 
    mSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeFrom:)];
    
    [mSwipeRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    
    [[self view] addGestureRecognizer:mSwipeRecognizer];
    
    [mSwipeRecognizer release];
    
    /*
    settingsAutoArray = [[NSArray alloc]initWithObjects:@"Auto Checkins",nil];
    
    autoCheckInSwitch = [[UISwitch alloc ] initWithFrame: CGRectMake(200, 5, 0, 0) ];
    if ([[sharedDelegate.searchingradies valueForKey:@"autocheckin"] isEqualToString:@"YES"]) {
        autoCheckInSwitch.on = YES;
    }
    else {
        autoCheckInSwitch.on = NO;
    }
    autoCheckInSwitch.tag = 18;
    [autoCheckInSwitch addTarget:self action:@selector(autoCheckInSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
     */
    signoutArray=[[NSArray alloc]initWithObjects:@"", nil];
    UIImage *imaout = [UIImage imageNamed:@"signout.png"];
    signOut=[[UIButton alloc]initWithFrame:CGRectMake(10, 1, imaout.size.width,imaout.size.height)];
    [signOut setImage:imaout forState:UIControlStateNormal];
    [signOut setHidden:NO];
    [signOut setTag:12];
    [signOut addTarget:self action:@selector(logOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Distance Button
    searchingScopeDisplayArray = [[NSArray alloc] initWithObjects:@"5 miles",@"10 miles",@"20 miles",@"50 miles", @"50+ miles", nil];
    searchingScopeArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:50], [NSNumber numberWithInt:1000], nil];
    searchingDistanceButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 4, 180, 31)];
    dropDownView = [[DropDownView alloc] initWithArrayData:searchingScopeDisplayArray cellHeight:30 heightTableView:150 paddingTop:40 paddingLeft:-50 paddingRight:-10 refView:searchingDistanceButton animation:BLENDIN openAnimationDuration:0.5 closeAnimationDuration:-1];
    dropDownView.delegate = self;

    
    [searchingDistanceButton setHidden:NO];
    searchingDistanceButton.tag=17;
    [searchingDistanceButton addTarget:self action:@selector(searchingScopeChanged:) forControlEvents:UIControlEventTouchUpInside];

    
    settingsDetails=[NSUserDefaults standardUserDefaults];
    self.navigationBar.topItem.title = [sharedDelegate currentServer:@"Settings"];
    
  
 //   NSString *previousLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousLogin"];
    NSString *currentLogin = [sharedDelegate.userdetails objectForKey:@"login"];
    if (currentLogin == nil)
        currentLogin = @"unknown";
    self.activeLogin.text = currentLogin;
    self.appVersion.text = sharedDelegate.versionString;

}

#pragma mark -
#pragma mark DropDownViewDelegate

-(void)dropDownCellSelected:(NSInteger)returnIndex
{
    
    [searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:returnIndex] forState:UIControlStateNormal];
    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
    
    [settingsDetails setValue:[searchingScopeArray objectAtIndex:returnIndex] forKey:@"radies"];
    sharedDelegate.searchingradies=[NSUserDefaults standardUserDefaults];
    [sharedDelegate.searchingradies setValue:[searchingScopeArray objectAtIndex:returnIndex] forKey:@"radies"];
    [settingsDetails setValue:[searchingScopeDisplayArray objectAtIndex:returnIndex] forKey:@"title"];
}

-(void)searchingScopeChanged:(id)sender{
    sharedDelegate.isSelectedDisButton = YES;
    [dropDownView openAnimation];
}


-(IBAction)backgroundClicked:(id)sender{
 
    [dropDownView closeAnimation];
   }

#pragma mark -
#pragma mark tableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
 //       case 0:
 //           return 0;
 //           break;
        case 0:
            return [settingsDisArray count];
            break;
        /*case 2:
            return [settingsAutoArray count];
            break;*/
        case 1:
            return [signoutArray count];
            break;
    }
    
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
 //       case 0:
 //           return sharedDelegate.versionString;
 //           break;
        case 0:
 //           return @"Current Settings";
             return @"";
            break;
        /*case 2:
            return @"Checkin Options";
            break;*/
        case 1:
            return @"";
            break;
    }
    
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"MYCELL";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    
 //   if (indexPath.section == 0) {
 //       switch ([indexPath row]) {
 //           case 0:
 //               break;
 //           default:
 //               break;
 //       }
 //   }
 //   else
    if (indexPath.section == 0) {
        switch ( [indexPath row]) {
            case 0:
                cell.textLabel.text = [settingsDisArray objectAtIndex: [indexPath row]];
                cell.backgroundColor = [UIColor lightGrayColor];
                NSString *title=[[NSUserDefaults standardUserDefaults]stringForKey:@"title"];
                if ([title length]!=0) {
                    
                    [searchingDistanceButton setTitle:title forState:UIControlStateNormal];
                    searchingDistanceButton.backgroundColor = [UIColor clearColor];
                    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
                }
                else{
                    [searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:1] forState:UIControlStateNormal];
                    searchingDistanceButton.backgroundColor = [UIColor clearColor];
                    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
                }                
                [cell addSubview: searchingDistanceButton];
                [self.view addSubview:dropDownView.view];
                break;
             default:
                break;
        }
    }
    /*else if(indexPath.section == 2) {
        switch ( [indexPath row]) {
            case 0:
                cell.textLabel.text = [settingsAutoArray objectAtIndex: [indexPath row]];
                NSString *autocheckin=[[NSUserDefaults standardUserDefaults]stringForKey:@"autocheckin"];
                if ([autocheckin isEqualToString:@"YES"]) {
                    [autoCheckInSwitch setOn:YES];
                }
                else{
                    [autoCheckInSwitch setOn:NO];
                }
                [cell addSubview:autoCheckInSwitch];
                break;
            default:
                break;
        }
    }*/
    else if(indexPath.section==1){
        switch (indexPath.row) {
            case 0 :
                [signOut setImage:[UIImage imageNamed:@"signout.png"] forState:UIControlStateNormal];
                [cell addSubview:signOut];
                break;
            default:
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 35;   
    
}



-(void)logOutButtonClicked:(id)sender{
    [sharedDelegate.searchingradies setValue:@"" forKey:@"useremail"];
    [sharedDelegate.searchingradies setValue:@"" forKey:@"password"];
    [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
    [sharedDelegate.searchingradies setValue:@"" forKey:@"firstname"];
    [sharedDelegate.searchingradies setValue:@"" forKey:@"last_name"];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [sharedDelegate.searchingradies setValue:@"" forKey:@"dataforlocal"];
    [sharedDelegate.searchingradies synchronize];
    [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
    [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
    [sharedDelegate.userdetails setValue:@"" forKey:@"userId"];
    [sharedDelegate.userdetails synchronize];
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    
    [keychain setObject:@"" forKey:(id)kSecAttrAccount];
    [keychain setObject:@"" forKey:(id)kSecValueData];
    
    sharedDelegate.isSignout=YES;
    sharedDelegate.isSelectedDisButton=YES;
    sharedDelegate.myOffersUpdate=NO;
    
 //   AppDelegate *sharedDelegate2 = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
  //    [self.navigationController popViewControllerAnimated:YES];
    
}


/*-(void)autoCheckInSwitchValueChanged:(id)sender{
	if (autoCheckInSwitch.on) {
        [sharedDelegate.searchingradies setValue:@"YES" forKey:@"autocheckin"];
    }
    else{
        [sharedDelegate.searchingradies setValue:@"NO" forKey:@"autocheckin"];
    }
}*/




- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [settingsTableView release];
    [signoutArray release];
    [autoCheckInSwitch release],[pushNotificationSwitch release];
    [searchingDistanceButton release];
    [versionLabel release];                           
    [settingsDetails release];
    [dropDownView release];
    [sharedDelegate release];
    [settingsAutoArray release];
    [settingsDisArray release];
    [settingsPushArray release];
    [signin release];
    [searchingScopeArray release];
    [searchingScopeDisplayArray release];
    [autoCheckInSwitch release];
    [pushNotificationSwitch release];
    [signOut release];
}

@end
