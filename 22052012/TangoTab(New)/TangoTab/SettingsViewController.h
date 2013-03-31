//
//  SettingsViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DropDownView.h"
#import "HeaderFiles.h"
#import "KeychainItemWrapper.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface SettingsViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,DropDownViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;

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
@end
