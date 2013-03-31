//
//  ViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
#import "KeychainItemWrapper.h"
#import "defines.h"
#import "AppDelegate.h"
#import "ForgetPasswordViewController.h"
#import "FlurryAnalytics.h"
#import "EasyTracker.h"
#import "GANTracker.h"
#import "SignUpViewController.h"
#import "NearMeViewController.h"
#import "SearchViewController.h"
#import "MyOffersViewController.h"
#import "SettingsViewController.h"
#import <CommonCrypto/CommonHMAC.h>
#import "CheckinViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@class CheckinViewController;
@class FlurryAnalytics;
@class ForgetPasswordViewController;
@class ASIHTTPRequest;
@class LoginView;
@class ActivityIndicatorView;
@class ZipcodeView;
@class ZipcodeUpdateView;


extern NSString * const NotifyProcessLocalNotifcations;

@interface ViewController : TrackedUIViewController <FBUserSettingsDelegate, UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tabview;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) NSArray *logArray;
@property (nonatomic, retain) UISwitch *rememberSwitch;
@property (nonatomic, retain) IBOutlet UIButton *forgetButton;
@property (nonatomic, retain) IBOutlet UIButton *signInBtn;
@property (nonatomic, retain) IBOutlet UIButton *signUpBtn;


@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) NSMutableArray *userArray,*localNotiArray;
@property (nonatomic, retain) NSMutableDictionary *userDict;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableString *user_id,*first_name,*last_name,*zip_code,*mobile_phone,*promo_code,*count_Message;
@property BOOL failed;
@property (nonatomic, retain) FBProfilePictureView *userProfileImage;

@property (nonatomic, retain) CheckinViewController *checkinViewCtrl;
@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ForgetPasswordViewController *forPasswordViewCtrl;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic,retain)  KeychainItemWrapper *keychain;
@property (nonatomic,retain)  LoginView *loginView;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain)  ZipcodeView *zipcodeView;
@property (nonatomic,retain)  ZipcodeUpdateView *zipcodeUpdateView;
@property (nonatomic,retain)  NSString *fbEmail, *fbFirstName, *fbLastName, *fbZipcode;

//-( void) sendASIHTTPRequest:(NSString*)serverURLs;
-(NSString*) sha256:(NSString *)clear;
- (void) user_validation;
- (void) parseXML:(NSString *) xmlString;
- (UITabBarController*)tabBarController;

-(void) facebookSignupComplete;
-(void) facebookSignupFailed;

@end
