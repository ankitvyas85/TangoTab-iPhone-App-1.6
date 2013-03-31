//
//  SettingsViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DropDownView.h"
#import "KeychainItemWrapper.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "EasyTracker.h"
#import "GANTracker.h"

@interface SettingsViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,DropDownViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) IBOutlet UILabel *activeLogin;

@property (nonatomic, retain) IBOutlet UILabel *appVersion;

@property (nonatomic, retain) NSArray *settingsDisArray,*settingsAutoArray,*settingsPushArray;
@property (nonatomic, retain) NSArray *signoutArray;
@property (nonatomic, retain) UISwitch *autoCheckInSwitch,*pushNotificationSwitch;
@property (nonatomic, retain) UIButton *searchingDistanceButton,*signOut;
@property (nonatomic, retain) UILabel *versionLabel;
@property (nonatomic, retain) NSArray *searchingScopeDisplayArray,*searchingScopeArray;
@property (nonatomic, retain) NSUserDefaults *settingsDetails;

@property (nonatomic, retain) DropDownView *dropDownView;

@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ViewController *signin;
@property (nonatomic, retain) KeychainItemWrapper *keychain;

@property (nonatomic) BOOL leftSwipeOne, leftSwipeTwo, rightSwipe;

-(IBAction)backgroundClicked:(id)sender;

@end
