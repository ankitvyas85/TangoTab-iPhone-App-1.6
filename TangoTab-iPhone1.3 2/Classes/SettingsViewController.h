//
//  SettingsViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserValidationParser.h"
#import "ActivityIndicatorView.h"
#import "DropDownView.h"
#import "EasyTracker.h"

@protocol UserSettingsDelegate <NSObject>
- (void)saveObject:(id)object;
@end


@interface SettingsViewController : TrackedUIViewController <DropDownViewDelegate> {

	IBOutlet UITableView *settingsTableView;
	
	NSMutableArray *sharingOptionsArray;
	NSMutableArray *checkInOptionsArray;
	NSMutableArray *loginArray;
	
	UISwitch *autoCheckInSwitch,*rememberSwitch;
	UISwitch *pushNotificationSwitch;
	UISwitch *facebookSwitch;
	UISwitch *twitterSwitch;
	UITextField *userNameTextField;
	UITextField *passwordTextField;
    UITextField *searchingRadiusTextFiled;
	
	UIBarButtonItem *doneButton;
	UIBarButtonItem *logOutButton;
	
	NSMutableArray *elementStack1;
	
	UserValidationParser *userValidationParser;
	ActivityIndicatorView *activityIndicatorView;
    
    NSMutableDictionary *settingsDict;
    
    id <UserSettingsDelegate> delegate;
    
    UIButton *searchingDistanceButton;
	NSArray *searchingScopeArray;
    NSArray *searchingScopeDisplayArray;
	DropDownView *dropDownView;
    
    //Gopal
    UIButton *remberButton; 
    BOOL checked;

}

//Gopal***
- (void)checkAction:(id)sender;
@property (nonatomic, assign) BOOL checked;
-(void)user_validation:(NSNotification *)pNotification;
//Gopal***
@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;
@property (nonatomic, retain) NSMutableArray *sharingOptionsArray;
@property (nonatomic, retain) NSMutableArray *checkInOptionsArray;
@property (nonatomic, retain) NSMutableArray *loginArray;

@property (nonatomic, retain) UISwitch *autoCheckInSwitch;
@property (nonatomic, retain) UISwitch *pushNotificationSwitch;
@property (nonatomic, retain) UISwitch *facebookSwitch;
@property (nonatomic, retain) UISwitch *twitterSwitch;
@property (nonatomic, retain) UITextField *userNameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) UITextField *searchingRadiusTextField;

@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *logOutButton;
@property (nonatomic, retain) NSMutableArray *elementStack1;
@property (nonatomic, retain) UserValidationParser *userValidationParser;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) NSMutableDictionary *settingsDict;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIButton *searchingDistanceButton;
@property (nonatomic, retain) NSArray *searchingScopeArray;
@property (nonatomic, retain) NSArray *searchingScopeDisplayArray;
@property (nonatomic, retain) DropDownView *dropDownView;

- (void)setValuesToPlistFile;
- (void)showActivityIndicatorView;
- (void)stopActivityIndicatorView;
- (void)setLoginCredentials;
- (void)searchingRadiusTextFieldDone;

@end
