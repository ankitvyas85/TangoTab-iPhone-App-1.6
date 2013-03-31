//
//  SettingsViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize settingsTableView;
@synthesize settingsDisArray,settingsAutoArray,settingsPushArray;
@synthesize autoCheckInSwitch,pushNotificationSwitch;
@synthesize searchingDistanceButton,signOut;
@synthesize versionLabel,dropDownView,searchingScopeArray,searchingScopeDisplayArray,settingsDetails,sharedDelegate;
@synthesize signoutArray;
@synthesize signin,keychain;

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

    self.settingsTableView.allowsSelection = NO;
     self.navigationController.navigationBarHidden=YES;
    sharedDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];

    settingsDisArray = [[NSArray alloc] initWithObjects:@"Distance to offers", nil];
    
    //settingsAutoArray = [[NSArray alloc]initWithObjects:@"Auto Checkins",nil];
    
    settingsPushArray = [[NSArray alloc]initWithObjects:nil];
    
    
    
//    autoCheckInSwitch = [[UISwitch alloc ] initWithFrame: CGRectMake(200, 5, 0, 0) ];
//    autoCheckInSwitch.on = YES;
//    autoCheckInSwitch.tag = 18;
//    [autoCheckInSwitch addTarget:self action:@selector(autoCheckInSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
//    
//    pushNotificationSwitch = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 5, 0, 0) ];
//    pushNotificationSwitch.on = YES;
//    pushNotificationSwitch.tag = 16;
//    [pushNotificationSwitch addTarget:self action:@selector(pushNotificationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
//    versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 5, 100, 30)];
//    versionLabel.backgroundColor = [UIColor clearColor];
//    versionLabel.font = [UIFont fontWithName:@"Verdana" size:16.0f];
//    versionLabel.textAlignment = UITextAlignmentCenter;
//    versionLabel.text = @"1.4";
    
    signoutArray=[[NSArray alloc]initWithObjects:@"", nil];
    UIImage *imaout = [UIImage imageNamed:@"signout.png"];
    signOut=[[UIButton alloc]initWithFrame:CGRectMake(10, 0, imaout.size.width,imaout.size.height)];
    [signOut setImage:imaout forState:UIControlStateNormal];
    [signOut setHidden:NO];
    [signOut setTag:12];
    [signOut addTarget:self action:@selector(logOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Distance Button
    searchingScopeDisplayArray = [[NSArray alloc] initWithObjects:@"5 miles",@"10 miles",@"20 miles",@"50 miles", @"50+ miles", nil];
    searchingScopeArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:50], [NSNumber numberWithInt:1000], nil];
    searchingDistanceButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 8, 180, 31)]; 
    dropDownView = [[DropDownView alloc] initWithArrayData:searchingScopeDisplayArray cellHeight:30 heightTableView:150 paddingTop:40 paddingLeft:-50 paddingRight:-10 refView:searchingDistanceButton animation:BLENDIN openAnimationDuration:0.5 closeAnimationDuration:-1];
    dropDownView.delegate = self;

    [searchingDistanceButton setHidden:NO];
   
    searchingDistanceButton.tag=17;
    [searchingDistanceButton addTarget:self action:@selector(searchingScopeChanged:) forControlEvents:UIControlEventTouchUpInside];
    settingsDetails=[NSUserDefaults standardUserDefaults];
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


#pragma mark -
#pragma mark tableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    switch (section) {
        case 0:
            return [settingsDisArray count];
            break;
        case 1:
            //return [settingsPushArray count];
            break;
        case 2:
            return [signoutArray count];
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Searching Scope Options";
            break;
        case 1:
            return @"Version                              1.4";
            break;
        case 2:
            return @"";
            break;
    }

	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"MYCELL";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    
   
    
    if (indexPath.section == 0) {
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = [settingsDisArray objectAtIndex: [indexPath row]];
                NSString *title=[[NSUserDefaults standardUserDefaults]stringForKey:@"title"];
                if ([title length]!=0) {
                    
                    [searchingDistanceButton setTitle:title forState:UIControlStateNormal];
                    searchingDistanceButton.backgroundColor = [UIColor clearColor];
                    searchingDistanceButton.titleLabel.textColor = [UIColor blackColor];
                }
                else{
                    [searchingDistanceButton setTitle:[searchingScopeDisplayArray objectAtIndex:3] forState:UIControlStateNormal];
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
//   else if (indexPath.section == 1) {
//        switch ( [indexPath row]) {
//            case 0:
//                cell.textLabel.text = [settingsAutoArray objectAtIndex: [indexPath row]];
//                NSString *autocheckin=[[NSUserDefaults standardUserDefaults]stringForKey:@"autocheckin"];
//                if ([autocheckin isEqualToString:@"YES"]) {
//                    [autoCheckInSwitch setOn:YES];
//                }
//                else{
//                    [autoCheckInSwitch setOn:NO];
//                }
//                [cell addSubview:autoCheckInSwitch];
//                break;
//            default:
//                break;
//        }
//    }
    else if (indexPath.section == 1) {
        switch ( [indexPath row]) {
//            case 0:
//                cell.textLabel.text = [settingsPushArray objectAtIndex: [indexPath row]];
//                NSString *pushnotification=[[NSUserDefaults standardUserDefaults]stringForKey:@"pushnotifications"];
//                if ([pushnotification  isEqualToString:@"YES"]) {
//                    [pushNotificationSwitch setOn:YES];
//                }
//                else{
//                    [pushNotificationSwitch setOn:NO];
//                }
//                [cell addSubview:pushNotificationSwitch];
//                break;
            case 0:
//                cell.textLabel.text = [settingsPushArray objectAtIndex: [indexPath row]];
//                [cell addSubview:versionLabel];
                break;                
            default:
                break;
        }
    }
    else if(indexPath.section==2){
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
    [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
    [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    
    [keychain setObject:@"" forKey:(id)kSecAttrAccount];
    [keychain setObject:@"" forKey:(id)kSecValueData]; 
    sharedDelegate.isSignout=YES;
    sharedDelegate.isSelectedDisButton=YES;
    sharedDelegate.myOffersUpdate=NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//-(void)autoCheckInSwitchValueChanged:(id)sender{
//	if (autoCheckInSwitch.on) {
//        [settingsDetails setValue:@"YES" forKey:@"autocheckin"];
//    }
//    else{
//        [settingsDetails setValue:@"NO" forKey:@"autocheckin"];
//    }
//}
//-(void)pushNotificationSwitchValueChanged:(id)sender{
//	if (pushNotificationSwitch.on) {
//        [settingsDetails setValue:@"YES" forKey:@"pushnotifications"];
//    }
//    else{
//        [settingsDetails setValue:@"NO" forKey:@"pushnotifications"];
//    }
//}

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
