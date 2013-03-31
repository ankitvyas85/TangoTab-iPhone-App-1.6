//
//  ViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "FacebookSignup.h"
#import "LoginView.h"
#import "ZipcodeView.h"
#import "IsActiveAccount.h"
#import "ZipcodeUpdateView.h"
#import "UpdateZipCode.h"

@implementation ViewController
@synthesize tabview,userNameTextField,passwordTextField,rememberSwitch,forgetButton, sharedDelegate, facebookButton;
@synthesize logArray,forPasswordViewCtrl;
@synthesize userArray,userDict,currentElement,user_id,first_name,last_name,zip_code,mobile_phone,count_Message,networkQueue,promo_code;
@synthesize failed,keychain,localNotiArray,checkinViewCtrl, userProfileImage, loginView, zipcodeView,zipcodeUpdateView;
@synthesize signInBtn, signUpBtn, activityIndicatorView, fbEmail, fbFirstName, fbLastName, fbZipcode;

bool facebookLogin = NO;
int facebookSignupAlert = 42;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)sessionStateChanged:(NSNotification*)notification {
    // A more complex app might check the state to see what the appropriate course of
    // action is, but our needs are simple, so just make sure our idea of the session is
    // up to date and repopulate the user's name and picture (which will fail if the session
    // has become invalid).
  
}

- (void)processLocalNotifications:(NSNotification*)notification {
    debug_NSLog(@"processing local notifications");
    localNotiArray =[[NSMutableArray alloc] init];
    checkinViewCtrl = [[CheckinViewController alloc] init];
    if([sharedDelegate.searchingradies objectForKey:@"dataforlocal"]) {
        localNotiArray = [[sharedDelegate.searchingradies arrayForKey:@"dataforlocal"] mutableCopy];
        if ([localNotiArray count]!=0) {
            for (int i =0; i < [localNotiArray count]; i++) {
                NSData *data = [localNotiArray objectAtIndex:i];
                UILocalNotification *localNotifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                debug_NSLog(@"localNotification = %@", localNotifi);
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss a"];
                NSDate *currDate = [dateFormatter dateFromString:sharedDelegate.currentDateString];
                NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
                [dateformstring setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
                NSString *resultDate = [dateformstring stringFromDate:currDate];
          //debug       resultDate = @"2012-10-22 11:00:00 PM";
                NSDate *currDate1 = [dateformstring dateFromString:resultDate];
                //        NSDate *compDate = [currDate1 dateByAddingTimeInterval:-14 * (24*60*60)];
                //        NSDate *fireDate = localNotifi.fireDate;
                if ([localNotifi.fireDate compare:currDate1] == NSOrderedAscending && [localNotifi.fireDate compare:[currDate1 dateByAddingTimeInterval:-14 * (24*60*60)]] == NSOrderedDescending) {
                    int c = [[localNotifi.userInfo objectForKey:@"isconsu"]integerValue];
                    if (c==0) {
                        NSString *convString = [NSString stringWithFormat:@"We hope you enjoyed your visit to %@ on %@",[localNotifi.userInfo objectForKey:@"busname"],[localNotifi.userInfo objectForKey:@"dealDate"]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:convString
                                                                        message:@"Were you able to attend?"
                                                                       delegate:self cancelButtonTitle:@"Yes"
                                                              otherButtonTitles:@"No",nil];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"dic"] forKey:@"dictionary"];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"userName"] forKey:@"userName"];
                        [sharedDelegate.searchingradies synchronize];
                        
                        [alert setTag:i];
                        [alert show];
                        break;
                    }
                }
            }
        }
    }
    
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.tabview.allowsSelection = NO;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processLocalNotifications:)
     name:NotifyProcessLocalNotifcations
     object:nil];

    
    if (!FBSession.activeSession.isOpen) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
           
            // even though we had a cached token, we need to login to make the session usable
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, 
                                                             FBSessionState status, 
                                                             NSError *error) {
                switch (status) {
                    case FBSessionStateOpen: {
                        int tabIndex = 1;
                        if ([sharedDelegate.urlActionController isEqualToString: @"searchViewController"])
                            tabIndex = 2;
                        UITabBarController *tab = [self tabBarController];
                        [tab setSelectedIndex: tabIndex];
                        [FlurryAnalytics logEvent:@"Near Me"];
                        [[self navigationController] pushViewController:tab animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
       
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    } 
    
    else {
       if (([[sharedDelegate.searchingradies objectForKey:@"useremail"]length]!=0 && [[sharedDelegate.searchingradies objectForKey:@"password"] length]!=0) || [[keychain objectForKey:(id)kSecAttrAccount] length]!=0) {
            [self user_validation];
            if ([[userDict valueForKey:@"first_name"] length] == 0) {
                if ([[userDict valueForKey:@"message"]length]!=0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[userDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release]; 
                }
            }
            else{
                NSString *zipcode = [userDict valueForKey:@"zip_code"];
                if (zipcode == NULL || [zipcode isEqualToString:@""])
                {
                    [self.view addSubview:self.zipcodeUpdateView];
                }
                else{
                
            
                    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-31920306-1"
                                                       dispatchPeriod:60
                                                             delegate:nil];
                    AppDelegate *sharedDelegate2 = (AppDelegate*)[[UIApplication sharedApplication]delegate];

                    NSString *email = [self sha256:[sharedDelegate.searchingradies valueForKey:@"useremail"]];
                    [FlurryAnalytics setUserID:email];
                    NSError *error;
                    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                                    name:@"UserId"
                                                                   value:email
                                                                   scope:kGANVisitorScope
                                                               withError:&error]){
                        NSLog(@"App Version Error Occured visitor");
                    }
                
                    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:5
                                                                    name:@"Source"
                                                                   value:[sharedDelegate.searchingradies valueForKey:@"promo_code"]
                                                                   scope:kGANVisitorScope
                                                               withError:&error]){
                        NSLog(@"Source PromoCode Error Occured visitor");
                    }
                    UITabBarController *tab = [self tabBarController];
                    int tabIndex = 1;
                    if ([sharedDelegate.urlActionController isEqualToString: @"searchViewController"])
                        tabIndex = 2;
                    [tab setSelectedIndex: tabIndex];
               
                    [FlurryAnalytics logEvent:@"Near Me"];
                    [[self navigationController] pushViewController:tab animated:YES];
                }
            }
        }
    }
    
  
    [self.signInBtn addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];

    [self.signUpBtn addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];

 
//    UIBarButtonItem *login = [[UIBarButtonItem alloc] initWithTitle: @"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signin:)];
    
//    [self.navigationItem setRightBarButtonItem:login];
    
 //   UIBarButtonItem *signin = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(signup:)];
    
 //   [self.navigationItem setLeftBarButtonItem:signin];
    
    logArray = [[NSArray alloc] initWithObjects:@"prompt",@"Email",@"Password",@"Keep me signed-in",@"",nil];
  //  logArray = [[NSArray alloc] initWithObjects:@"Email",@"Password",@"Keep me signed-in",@"",nil];
    

//    UIImage *fbimage = [UIImage imageNamed:@"connectViaFacebook.png"];
//
  //  facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 8,fbimage.size.width,fbimage.size.height)];
//    [facebookButton setImage:fbimage forState:UIControlStateNormal];
//    [facebookButton setHidden:NO];
//    [facebookButton setTag:14];
//    [facebookButton addTarget:self action:@selector(facebookButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [userNameTextField setPlaceholder:@"Enter Email"];
    [userNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
 //   [userNameTextField setBorderStyle:UITextBorderStyleBezel];
    [userNameTextField setSecureTextEntry:NO];
    [userNameTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [userNameTextField setReturnKeyType:UIReturnKeyNext];
    [userNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [userNameTextField addTarget:self action:@selector(userNameTextFieldNextClickedClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [passwordTextField setPlaceholder:@"Enter Password"];
    [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//    [passwordTextField setBorderStyle:UITextBorderStyleBezel];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordTextField setReturnKeyType:UIReturnKeyGo];
    [passwordTextField addTarget:self action:@selector(signin:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    rememberSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(200, 8, 79, 21)];
    [rememberSwitch setOn:YES];
    [rememberSwitch addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventValueChanged];
    
    [forgetButton setHidden:NO];
    [forgetButton setTag:13];
    [forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
 //   [self processLocalNotifications: nil];
 
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (alertView.tag == facebookSignupAlert) {
        return;
    }
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss a"];
    NSDate *currDate = [dateFormatter dateFromString:sharedDelegate.currentDateString];
    NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
    [dateformstring setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *resultDate = [dateformstring stringFromDate:currDate];
    NSDate *currDate1 = [dateformstring dateFromString:resultDate];

    if (buttonIndex == 0) {
        NSDictionary *temdic = [sharedDelegate.searchingradies objectForKey:@"dictionary"];
        NSString *username = [sharedDelegate.searchingradies objectForKey:@"userName"];
        [checkinViewCtrl autocheckin:@"A" autocheckDetail:temdic userName:username];
        NSData *data = [localNotiArray objectAtIndex:alertView.tag];
        UILocalNotification *localNotifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotifi];
        NSMutableArray *tem = [[sharedDelegate.searchingradies arrayForKey:@"dataforlocal"] mutableCopy];
        [tem removeObject:[tem objectAtIndex:alertView.tag]];
        NSArray *aa = tem;
        [sharedDelegate.searchingradies setValue:aa forKey:@"dataforlocal"];
        [sharedDelegate.searchingradies synchronize];
        [localNotiArray removeObject:[localNotiArray objectAtIndex:alertView.tag]];
        
                
        if ([localNotiArray count]!=0) {
            for (int i = 0; i < [localNotiArray count]; i++) {
                NSData *data = [localNotiArray objectAtIndex:i];
                UILocalNotification *localNotifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
               if ([localNotifi.fireDate compare:currDate1] == NSOrderedAscending && [localNotifi.fireDate compare:[currDate1 dateByAddingTimeInterval:-14 * (24*60*60)]] == NSOrderedDescending) {
                    int c = [[localNotifi.userInfo objectForKey:@"isconsu"]integerValue];
                    if (c==0) {
                     
                        NSString *convString = [NSString stringWithFormat:@"We hope you enjoyed your visit to %@ on %@",[localNotifi.userInfo objectForKey:@"busname"],[localNotifi.userInfo objectForKey:@"dealDate"]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:convString 
                                                                        message:@"Were you able to attend?"
                                                                       delegate:self cancelButtonTitle:@"Yes" 
                                                              otherButtonTitles:@"No",nil];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"dic"] forKey:@"dictionary"];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"userName"] forKey:@"userName"];
                        [sharedDelegate.searchingradies synchronize];
                        [alert setTag:i];
                        [alert show];
                        break;
                    }
                }
            }
        }
    }
    if (buttonIndex == 1) {
        NSDictionary *temdic = [sharedDelegate.searchingradies objectForKey:@"dictionary"];
        NSString *username = [sharedDelegate.searchingradies objectForKey:@"userName"];
        [checkinViewCtrl autocheckin:@"NA" autocheckDetail:temdic userName:username];
        NSData *data = [localNotiArray objectAtIndex:alertView.tag];
        UILocalNotification *localNotifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotifi];
        NSMutableArray *tem = [[sharedDelegate.searchingradies arrayForKey:@"dataforlocal"] mutableCopy];
        [tem removeObject:[tem objectAtIndex:alertView.tag]];
        NSArray *aa = tem;
        [sharedDelegate.searchingradies setValue:aa forKey:@"dataforlocal"];
        [sharedDelegate.searchingradies synchronize];
        [localNotiArray removeObject:[localNotiArray objectAtIndex:alertView.tag]];
        
        
        if ([localNotiArray count]!=0) {
            for (int i =0; i <[localNotiArray count]; i++) {
                NSData *data = [localNotiArray objectAtIndex:i];
                UILocalNotification *localNotifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([localNotifi.fireDate compare:currDate1] == NSOrderedAscending && [localNotifi.fireDate compare:[currDate1 dateByAddingTimeInterval:-14 * (24*60*60)]] == NSOrderedDescending) {
                    int c = [[localNotifi.userInfo objectForKey:@"isconsu"]integerValue];
                    if (c==0) {
                        NSString *convString = [NSString stringWithFormat:@"We hope you enjoyed your visit to %@ on %@",[localNotifi.userInfo objectForKey:@"busname"],[localNotifi.userInfo objectForKey:@"dealDate"]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:convString 
                                                                        message:@"Were you able to attend?"
                                                                       delegate:self cancelButtonTitle:@"Yes" 
                                                              otherButtonTitles:@"No",nil];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"dic"] forKey:@"dictionary"];
                        [sharedDelegate.searchingradies setValue:[localNotifi.userInfo objectForKey:@"userName"] forKey:@"userName"];
                        [sharedDelegate.searchingradies synchronize];
                        [alert setTag:i];
                        [alert show];
                        break;
                    }
                }
            } 
        }
    }
}


-(void)viewWillAppear:(BOOL)animated{
    rememberSwitch.on=YES;
    [userNameTextField becomeFirstResponder];
    [passwordTextField resignFirstResponder];
    [super viewWillAppear:YES];

    self.loginView = [[LoginView alloc] initWithFrame:self.view.bounds];
    self.zipcodeView = [[ZipcodeView alloc] initWithFrame:self.view.bounds];
    self.zipcodeUpdateView = [[ZipcodeUpdateView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.loginView];
    [self.loginView release];
    [userNameTextField resignFirstResponder];
    
    [self.zipcodeView.homeZipCode setReturnKeyType:UIReturnKeyNext];
    [self.zipcodeView.homeZipCode setKeyboardType: UIKeyboardTypeNumbersAndPunctuation];

    [self.zipcodeView.workZipCode setReturnKeyType:UIReturnKeyGo];
    [self.zipcodeView.homeZipCode  addTarget:self action:@selector(homeZipCodeNextClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.zipcodeView.homeZipCode setKeyboardType: UIKeyboardTypeNumbersAndPunctuation];

    [self.zipcodeView.workZipCode  addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
 
    [self.zipcodeUpdateView.homeZipCode setKeyboardType: UIKeyboardTypeNumbersAndPunctuation];
    [self.zipcodeUpdateView.homeZipCode setReturnKeyType:UIReturnKeyNext];
    [self.zipcodeUpdateView.workZipCode setKeyboardType: UIKeyboardTypeNumbersAndPunctuation];

    [self.zipcodeUpdateView.workZipCode setReturnKeyType:UIReturnKeyGo];
    [self.zipcodeUpdateView.homeZipCode  addTarget:self action:@selector(updateHomeZipCodeNextClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.zipcodeUpdateView.workZipCode  addTarget:self action:@selector(updateButtonClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.zipcodeUpdateView.updateBtn  addTarget:self action:@selector(updateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self.loginView.facebookBtn addTarget:self action:@selector(facebookButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.signInBtn addTarget:self action:@selector(signInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.signUpBtn addTarget:self action:@selector(signUpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.zipcodeView.createBtn addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    NSString *sl = [sharedDelegate currentServer:@""];
    self.loginView.serverLabel.text = sl;


}

-(void)signInButtonClicked:(id)sender {
    [self stopActivityIndicatorView];
    [self.loginView removeFromSuperview];
}

-(void)createButtonClicked:(id)sender {
    [self.zipcodeView removeFromSuperview];
     // set zip code
    self.fbZipcode = [self.zipcodeView.homeZipCode text];
    if ([self.fbZipcode isEqualToString: @""])
         self.fbZipcode = [self.zipcodeView.workZipCode text];
    if ([self.fbZipcode isEqualToString: @""])
        self.fbZipcode = sharedDelegate.currentZipCode;
    FacebookSignup *fbsignup = [[FacebookSignup alloc] init];
    fbsignup.viewController = self;
    [fbsignup  signupWithToken: [sharedDelegate.userdetails objectForKey: @"psw"] email: self.fbEmail firstName: fbFirstName LastName: self.fbLastName zipCode:fbZipcode];
   
}

-(void)updateButtonClicked:(id)sender {
    [self.zipcodeUpdateView removeFromSuperview];
    NSString *newZipCode = [self.zipcodeUpdateView.homeZipCode text];
    if ([newZipCode isEqualToString: @""])
        newZipCode = [self.zipcodeUpdateView.workZipCode text];
    if ([newZipCode isEqualToString: @""])
        newZipCode = sharedDelegate.currentZipCode;
    
    // update zip code
    UpdateZipCode *webService = [[UpdateZipCode alloc] init];
    BOOL result = [webService invokeWithEmailAddress: [sharedDelegate.userdetails objectForKey: @"login"] zipCode:newZipCode];
    
    [self.loginView removeFromSuperview];
    int tabIndex = 1;
    if ([sharedDelegate.urlActionController isEqualToString: @"searchViewController"])
        tabIndex = 2;
    UITabBarController *tab = [self tabBarController];
    [tab setSelectedIndex: tabIndex];
    [FlurryAnalytics logEvent:@"Near Me"];
    [[self navigationController] pushViewController:tab animated:YES];
    
}

-(void)signUpButtonClicked:(id)sender {
    [self stopActivityIndicatorView];
    [self.loginView removeFromSuperview];
    SignUpViewController *singUpVCtrl = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    singUpVCtrl.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:singUpVCtrl animated:YES];
}


-(void)checkAction:(id)sender {

    if (rememberSwitch.on) {
        [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
    }
    else{
        [sharedDelegate.searchingradies setValue:@"NO" forKey:@"rememberSwitch"];
    }
}

-(void)forgetButtonClicked:(id)sender {
    
    forPasswordViewCtrl = [[ForgetPasswordViewController alloc] initWithNibName:@"ForgetPasswordViewController" bundle:[NSBundle mainBundle]];
    
    [self presentModalViewController:forPasswordViewCtrl animated:YES];
}

-(void) facebookSignupFailed {
    [self stopActivityIndicatorView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Sorry, we could not connect you via Facebook." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
   [alert setTag:facebookSignupAlert];
    [alert show];
    [alert release];

    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
//    self.view.hidden = NO;
//    for (UIView *view in [self.view subviews]) {
//        view.hidden=NO;
//    }

}

-(void) facebookSignupComplete {
    
    NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",sharedDelegate.activeServerUrl,[sharedDelegate.userdetails objectForKey: @"login"],[sharedDelegate.userdetails objectForKey: @"psw"]];
    NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    [self parseXML:terString];
    
    NSString *userId = [userDict valueForKey:@"user_id"];
    NSString *zipcode = [userDict valueForKey:@"zip_code"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (userId == NULL)
    {
        if (FBSession.activeSession.isOpen) {
            [FBSession.activeSession closeAndClearTokenInformation];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Sorry, we could not connect you via Facebook." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setTag:facebookSignupAlert];
        [alert show];
        [alert release];
    }
    else
    if (zipcode == NULL || [zipcode isEqualToString:@""])
    {
         [self.view addSubview:self.zipcodeUpdateView];
    }
    else
    {
        [self.loginView removeFromSuperview];
        int tabIndex = 1;
        if ([sharedDelegate.urlActionController isEqualToString: @"searchViewController"])
            tabIndex = 2;
        UITabBarController *tab = [self tabBarController];
        [tab setSelectedIndex: tabIndex];
        [FlurryAnalytics logEvent:@"Near Me"];
        [[self navigationController] pushViewController:tab animated:YES];
    }
    [self stopActivityIndicatorView];
//    self.view.hidden = NO;
//    for (UIView *view in [self.view subviews]) {
//        view.hidden=NO;
//    }

}

-(void)facebookButtonClicked:(id)sender {
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email", @"user_likes", @"user_checkins",@"user_location",@"user_birthday", 
                            @"offline_access", nil];
//    self.view.hidden = YES;
//    for (UIView *view in [self.view subviews]) {
//        view.hidden=YES;
//    }
    [userNameTextField resignFirstResponder];
    [self showActivityIndicatorView];
    [FBSession openActiveSessionWithPermissions:permissions
                                   allowLoginUI:YES
                              completionHandler:^(FBSession *session,
                                                  FBSessionState state,
                                                  NSError *error) {
        // and here we make sure to update our UX according to the new session state
        // we recurse here, in order to update buttons and labels
        switch (state) {
            case FBSessionStateOpen: {
                
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                     if (!error) {
                         sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

                          NSString *userName = user.name;
                          NSString *facebookId = user.id;
                          NSString *userLocation = user.location.name;
                          self.fbEmail = [user objectForKey:@"email"];
                          debug_NSLog(@"facebook user id = %@", facebookId);
                          debug_NSLog(@"facebook user name = %@", userName);
                          debug_NSLog(@"facebook location = %@", userLocation);
                          debug_NSLog(@"facebook email = %@", self.fbEmail);
                          self.fbZipcode = sharedDelegate.currentZipCode;
                          debug_NSLog(@"current ZipCode = %@", sharedDelegate.currentZipCode);
                          NSString *fbId = @"fbid";
                          fbId = [fbId stringByAppendingString:facebookId];
                         [sharedDelegate.userdetails setValue:fbId forKey:@"psw"];
                         [sharedDelegate.userdetails synchronize];

                         
                          self.zipcodeView.workZipCode.text = sharedDelegate.currentZipCode;
                          self.zipcodeView.homeZipCode.text = sharedDelegate.currentZipCode;
                         
                          userNameTextField.text = @"";
                        
                //         [sharedDelegate.userdetails setValue:[user objectForKey:@"email"] forKey:@"login"];
                //         [sharedDelegate.userdetails synchronize];
                          facebookLogin = YES;
                //         NSString *firstName = @"";
                //         NSString *lastName = @"";
                         
                         NSArray *splitName = [userName componentsSeparatedByString:@" "];
                         
                         self.fbFirstName = (NSString*)[splitName objectAtIndex:0];
                         self.fbLastName = (NSString*)[splitName objectAtIndex:1];
                       
                         // Test Cases
                         // 1. Facebook Login, existing email account
                         
                         // 2. Facebook Login, no existing account
                         // 3. Facebool Login, existing eamil account different than email address returned by facebook (link account)
                         
                         IsActiveAccount *webService = [[IsActiveAccount alloc] init];
                         ActiveAccountType validAccount = [webService invokeWithEmailAddress: self.fbEmail facebookId:facebookId];
                         // if the account does not exist and their is a previous login, use it
                         if (validAccount == NotValid)
                         {
                             NSString *existingLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousLogin"];
                             
                             if (existingLogin != nil && ![existingLogin isEqualToString:@""])
                             {
                                 self.fbEmail = existingLogin;
                                 validAccount = Valid;
                             }
                         }
                         else
                         if (validAccount == Linked)
                         {
                             self.fbEmail = webService.linkedAccount;
                             validAccount = Valid;
                         }
                         if (validAccount == NotValid)
                         {
                             [sharedDelegate.userdetails setValue:self.fbEmail forKey:@"login"];
                             [sharedDelegate.userdetails synchronize];
                             [self.view addSubview:self.zipcodeView];
                         }
                         else
                         {                        
                            [self.loginView removeFromSuperview];
                            [sharedDelegate.userdetails setValue:self.fbEmail forKey:@"login"];
                            [sharedDelegate.userdetails synchronize];
                            userDict=nil;
                            NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",sharedDelegate.activeServerUrl,self.fbEmail,[sharedDelegate.userdetails objectForKey: @"psw"]];
                             NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                             [self parseXML:terString];
                             NSString *zipcode = [userDict valueForKey:@"zip_code"];
                             if (zipcode == NULL || [zipcode isEqualToString:@""])
                             {
                                 [self.view addSubview:self.zipcodeUpdateView];
                             }
                             else
                             {
                                 int tabIndex = 1;
                                 if ([sharedDelegate.urlActionController isEqualToString: @"searchViewController"])
                                 tabIndex = 2;
                                 UITabBarController *tab = [self tabBarController];
                                 [tab setSelectedIndex: tabIndex];
                                 [FlurryAnalytics logEvent:@"Near Me"];
                                 [[self navigationController] pushViewController:tab animated:YES];
                             }
                             
                         }
                //         FacebookSignup *fbsignup = [[FacebookSignup alloc] init];
                //         fbsignup.viewController = self;
                //         [fbsignup  signupWithToken: [sharedDelegate.userdetails objectForKey: @"psw"] email: userEmail firstName: firstName LastName: lastName zipCode:sharedDelegate.currentZipCode];
                         
                        
                  
                     }
                 }];
                
 
            }
            break;
            default:
            break;
        }
        
    }];
    
   }

- (void)showActivityIndicatorView {
	CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, cgSize.width, cgSize.height)];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, cgSize.width, cgSize.height)];
		[self.view addSubview:activityIndicatorView];
	}
}

-(void)stopActivityIndicatorView{
	[activityIndicatorView removeActivityIndicator];
}


-(NSString*) sha256:(NSString *)clear{
    
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    
    CC_SHA256(keyData.bytes, keyData.length, digest);
    
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    NSString *hash=[out description];
    
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
    
}


-(IBAction)signup :(id)sender {
    SignUpViewController *singUpVCtrl = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    singUpVCtrl.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:singUpVCtrl animated:YES];
}


-(IBAction) signin :(id)sender {

    [userNameTextField becomeFirstResponder];
    [passwordTextField becomeFirstResponder];
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
        if ([userNameTextField.text length] ==0 || [passwordTextField.text length] ==0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide valid Login information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else {
            if (rememberSwitch.on) {
                [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
            }
            else{
                [sharedDelegate.searchingradies setValue:@"NO" forKey:@"rememberSwitch"];
            }
            [self user_validation];
            if ([[userDict valueForKey:@"first_name"] length] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[userDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release]; 
            }
            else {
                NSString *zipcode = [userDict valueForKey:@"zip_code"];
                if (zipcode == NULL || [zipcode isEqualToString:@""])
                {
                    [self.view addSubview:self.zipcodeUpdateView];
                }
                else{
                    NSError *error = nil;
                    if (![[GANTracker sharedTracker] trackEvent:@"Sign In Button"
                                                     action:@"TrackEvent"
                                                      label:@"Sign In"
                                                      value:-1
                                                  withError:&error]) {
                        NSLog(@"Error Occured");
                    }
                
                    AppDelegate *sharedDelegate2 = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                 
                    NSString *email = [self sha256:[sharedDelegate.searchingradies valueForKey:@"useremail"]];
                    [FlurryAnalytics setUserID:email];
                
               
                    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-31920306-1"
                                                       dispatchPeriod:60
                  
                                                             delegate:nil];
                 
                    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                                    name:@"UserId"
                                                                   value:email
                                                                   scope:kGANVisitorScope
                                                               withError:&error]){
                        NSLog(@"App Version Error Occured visitor");
                    }
                    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:5
                                                                    name:@"Source"
                                                                   value:[sharedDelegate.searchingradies valueForKey:@"promo_code"]
                                                                   scope:kGANVisitorScope
                                                               withError:&error]){
                        NSLog(@"Source PromoCode Error Occured visitor");
                    }
                    if (sharedDelegate.isSignout==YES) {
                        sharedDelegate.isSignout=NO;
                        UITabBarController *signTab = [self tabBarController];
                    
                        [signTab setSelectedIndex:1];
                        [FlurryAnalytics logEvent:@"Near Me"];
                        [[self navigationController] pushViewController:signTab animated:YES];
                    }
                    else {
                        UITabBarController *signTab = [self tabBarController];
                        [signTab setSelectedIndex:1];
                        [FlurryAnalytics logEvent:@"Near Me"];
                        [[self navigationController] pushViewController:signTab animated:YES];
                    }
                }
            }
        }
    }
}

- (UITabBarController*)tabBarController
{
    MyOffersViewController *myOffersVCtrl = [[MyOffersViewController alloc] initWithNibName:@"MyOffersViewController" bundle:[NSBundle mainBundle]];
    
    UINavigationController *myOfferNavCtrl =  [[UINavigationController alloc] initWithRootViewController:myOffersVCtrl];
    
    UITabBarItem *myOfferBarItem = [[UITabBarItem alloc] initWithTitle:@"My Offers" image:[UIImage imageNamed:@"MyOffers.png"] tag:100];
    
    [myOfferNavCtrl setTabBarItem:myOfferBarItem];
    NearMeViewController *nearVCtrl = [[NearMeViewController alloc] initWithNibName:@"NearMeViewController" bundle:[NSBundle mainBundle]];
    
   UINavigationController *nearNavCtrl =  [[UINavigationController alloc] initWithRootViewController:nearVCtrl];
    
    UITabBarItem *nearMeBarItem = [[UITabBarItem alloc] initWithTitle:@"Near Me" image:[UIImage imageNamed:@"NearMe.png"] tag:101];
    
    [nearNavCtrl setTabBarItem:nearMeBarItem];
    
    SearchViewController *searchVCtrl = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle mainBundle]];
    
   UINavigationController *seaNavCtrl =  [[UINavigationController alloc] initWithRootViewController:searchVCtrl];
    
    UITabBarItem *searchBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"Search.png"] tag:102];
    
    [seaNavCtrl setTabBarItem:searchBarItem];
    
     SettingsViewController *settingsVCtrl = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    
    UITabBarItem *settingsBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"Settings.png"] tag:103];
    
    [settingsVCtrl setTabBarItem:settingsBarItem];
    
    UITabBarController *tabController2 = [[UITabBarController alloc] init];
    [tabController2 setDelegate:self];
    [tabController2 setViewControllers:[NSArray arrayWithObjects:myOfferNavCtrl,nearNavCtrl,seaNavCtrl,settingsVCtrl,nil]];
    
    
    [myOfferNavCtrl release];
    [myOffersVCtrl release];
    [nearNavCtrl release];
    [nearVCtrl release];
    [searchVCtrl release]; 
    [seaNavCtrl release];
    [settingsVCtrl release];
    
    return tabController2;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
     NSError *error;
    switch (tabBarController.selectedIndex) {
        case 0:
            if (![[GANTracker sharedTracker] trackEvent:@"My Offers"
                                                 action:@"TrackEvent"
                                                  label:@"My Offers Clicked"
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            [FlurryAnalytics logEvent:@"My Offers"];
            break;
        case 1:
            if (![[GANTracker sharedTracker] trackEvent:@"Near Me"
                                                 action:@"TrackEvent"
                                                  label:@"Near Me Clicked"
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            [FlurryAnalytics logEvent:@"Near Me"];
            break;
        case 2:
            break;
        case 3:
            if (![[GANTracker sharedTracker] trackEvent:@"Settings"
                                                 action:@"TrackEvent"
                                                  label:@"Settings Clicked"
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            [FlurryAnalytics logEvent:@"Settings"];
            break;
        default:
            if (![[GANTracker sharedTracker] trackEvent:@"Near Me"
                                                 action:@"TrackEvent"
                                                  label:@"Near Me Clicked"
                                                  value:-1
                                              withError:&error]) {
                NSLog(@"Error Occured");
            }
            [FlurryAnalytics logEvent:@"Near Me"];
            break;
    }
    
}


- (void) user_validation {
    @try {

        NSString *passwordStringEncoded;
        NSString *passwordString;
        NSString *userName;
        NSData* aData;
        keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
        if ([userNameTextField.text length]==0) {
            NSString *psw=[keychain objectForKey:(id)kSecValueData];
            aData  = [psw dataUsingEncoding: NSASCIIStringEncoding];
            passwordStringEncoded = [Base64 encode:aData];
            userName   = [keychain objectForKey:(id)kSecAttrAccount];
        } 
        else {
            [keychain setObject:@"" forKey:(id)kSecAttrAccount];
            [keychain setObject:@"" forKey:(id)kSecValueData];  
            [sharedDelegate.searchingradies setValue:@"" forKey:@"useremail"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"password"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"last_name"];
            [sharedDelegate.searchingradies synchronize];
            [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
            [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
            [sharedDelegate.userdetails setValue:@"" forKey:@"userId"];
            [sharedDelegate.userdetails synchronize];
            passwordString = [passwordTextField text];
            aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
            passwordStringEncoded = [Base64 encode:aData];
            userName = [userNameTextField text];
        }
        userDict=nil;
        
        NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",sharedDelegate.activeServerUrl,userName,passwordStringEncoded];
        NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
       
       [self parseXML:terString];
    }
    @catch (NSException *exception) {
        
    }
}

-(void) parseXML:(NSString *) xmlString
{
    userArray = [[NSMutableArray alloc] init];
    @try {
        
        NSURL *url = [NSURL URLWithString:[xmlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        debug_NSLog(@"WS-> %@",[url absoluteString]);
        NSData *xmlData = [NSData dataWithContentsOfURL:url];
        NSString *myString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        debug_NSLog(@"WSR <- %@", myString);
    
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        
        [parser setDelegate:self];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement=[[NSMutableString alloc]init];
    currentElement=[elementName copy];
    if ([elementName isEqualToString:@"user_details"]) {
        userDict     = [[NSMutableDictionary alloc]init];
        user_id      = [[NSMutableString alloc] init];
        first_name   = [[NSMutableString alloc] init];
        last_name    = [[NSMutableString alloc]init];
        zip_code     = [[NSMutableString alloc]init];
        mobile_phone = [[NSMutableString alloc]init];
        promo_code   = [[NSMutableString alloc]init];
    }
    else if ([elementName isEqualToString:@"message"]) {
        userDict     = [[NSMutableDictionary alloc]init];
        user_id      = [[NSMutableString alloc] init];
    }
    else if([elementName isEqualToString:@"success"]){
        count_Message=[[NSMutableString alloc]init];
    }
   
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([currentElement isEqualToString:@"user_id"]) {
        [user_id appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"first_name"]) {
        [first_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"last_name"]) {
        [last_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"zip_code"]) {
        [zip_code appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"mobile_phone"]) {
        [mobile_phone appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"promo_code"]) {
        [promo_code appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"message"]) {
        [user_id appendFormat:terstring];
    }
    else if([currentElement isEqualToString:@"success"]){
        [count_Message appendFormat:terstring];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{   
    if ([elementName isEqualToString:@"user_details"]) {
        [userDict setValue:user_id forKey:@"user_id"];
        [userDict setValue:first_name forKey:@"first_name"];
        [userDict setValue:last_name forKey:@"last_name"];
        [userDict setValue:zip_code forKey:@"zip_code"];
        [userDict setValue:mobile_phone forKey:@"mobile_phone"];
        [userDict setValue:promo_code forKey:@"promo_code"];
        [userArray addObject:userDict];
    }
    else if ([elementName isEqualToString:@"message"]) {
        [userDict setValue:user_id forKey:@"message"];
        [userArray addObject:userDict];
    }
    else if([elementName isEqualToString:@"success"]){
        [userDict setValue:count_Message forKey:@"count_message"];
        [userArray addObject:userDict];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{

    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    if ([[userDict objectForKey:@"first_name"]length]!=0) {
        if ([[sharedDelegate.searchingradies objectForKey:@"rememberSwitch"] isEqualToString:@"YES"]) {
            if ([userNameTextField.text length]!=0) {
                
                [keychain setObject:[userNameTextField text] forKey:(id)kSecAttrAccount];
                [keychain setObject:[passwordTextField text] forKey:(id)kSecValueData];    
                NSString * passwordString =[passwordTextField text];
                
                [[NSUserDefaults standardUserDefaults] setObject: [userNameTextField text] forKey:@"previousLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                               
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.searchingradies setValue:userNameTextField.text forKey:@"useremail"];
                [sharedDelegate.searchingradies setValue:passwordStringEncoded forKey:@"password"];
                [sharedDelegate.searchingradies synchronize];
                [sharedDelegate.userdetails setValue:userNameTextField.text forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails setValue:[userDict valueForKey:@"user_id"] forKey:@"userId"];
                [sharedDelegate.userdetails synchronize];
            }	
            else{
                NSString * passwordString =[keychain objectForKey:(id)kSecValueData] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.searchingradies setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"useremail"];
                [sharedDelegate.searchingradies setValue:passwordStringEncoded forKey:@"password"];
                [sharedDelegate.searchingradies synchronize];
                if (!facebookLogin)
                {
                    [sharedDelegate.userdetails setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"login"];
                    [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                }
                [sharedDelegate.userdetails setValue:[userDict valueForKey:@"user_id"] forKey:@"userId"];
                [sharedDelegate.userdetails synchronize];
            }
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"first_name"] forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"last_name"] forKey:@"last_name"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"promo_code"] forKey:@"promo_code"];
            [sharedDelegate.searchingradies synchronize];
        }
        else{
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"first_name"] forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"last_name"] forKey:@"last_name"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"promo_code"] forKey:@"promo_code"];
            [sharedDelegate.searchingradies synchronize];
            
            if ([userNameTextField.text length]!=0) {
                NSString * passwordString =[passwordTextField text] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.userdetails setValue:userNameTextField.text forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails setValue:[userDict valueForKey:@"user_id"] forKey:@"userId"];
                [sharedDelegate.userdetails synchronize];
                [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
            }
            else{
                NSString * passwordString =[keychain objectForKey:(id)kSecValueData] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                if (!facebookLogin) {
                    [sharedDelegate.userdetails setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"login"];
                    [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                }
                [sharedDelegate.userdetails setValue:[userDict valueForKey:@"user_id"] forKey:@"userId"];
                [sharedDelegate.userdetails synchronize];
            }
        }
    }
    else {
        if ([[sharedDelegate.searchingradies objectForKey:@"rememberSwitch"] isEqualToString:@"NO"] ) {
            [keychain setObject:@"" forKey:(id)kSecAttrAccount];
            [keychain setObject:@"" forKey:(id)kSecValueData];  
            [sharedDelegate.searchingradies setValue:@"" forKey:@"useremail"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"password"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"last_name"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"promo_code"];
            [sharedDelegate.searchingradies synchronize];
            [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
            [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
            [sharedDelegate.userdetails setValue:@"" forKey:@"userId"];
            [sharedDelegate.userdetails synchronize];
            [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
        }
    }
    userNameTextField.text=nil;
    passwordTextField.text=nil;
}


-(void)homeZipCodeNextClicked:(id)sender
{
    [self.zipcodeView.workZipCode becomeFirstResponder];
}

-(void)updateHomeZipCodeNextClicked:(id)sender
{
    [self.zipcodeUpdateView.workZipCode becomeFirstResponder];
}

-(void)userNameTextFieldNextClickedClicked:(id)sender
{
    [passwordTextField becomeFirstResponder];
}
-(void)passwordTextFieldNextClicked:(id)sender
{
    [passwordTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [logArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"MYCELL";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    NSInteger row = [indexPath row];
    
    switch (row) {
        case 0:
            cell.textLabel.text = @"Sign In with Email";
        break;
        case 1:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:userNameTextField];
            break;
        case 2:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:passwordTextField];
            break;
        case 3:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:rememberSwitch];
            break;
        case 4:
            [forgetButton setImage:[UIImage imageNamed:@"forgotpassword_btn.png"] forState:UIControlStateNormal];
            [cell addSubview:forgetButton];
            break;
        
        default:
            break;
    }

    return cell;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    
}

-(void)dealloc{
    [logArray release];
    [tabview release];
    [userNameTextField release];
    [passwordTextField release];
    [rememberSwitch release];
    [forgetButton release];
    [userArray release];
    [userDict release];
    [currentElement release];
    [user_id release];
    [first_name release];
    [last_name release];
    [zip_code release];
    [mobile_phone release];
 //   [sharedDelegate release];
    [forPasswordViewCtrl release];
    
}
@end
