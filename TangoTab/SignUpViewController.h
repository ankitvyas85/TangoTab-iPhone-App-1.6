//
//  SignUpViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TermsViewController.h"
#import "PrivacyPolicyViewController.h"
#import "defines.h"
#import "ActivityIndicatorView.h"
#import "AppDelegate.h"
#import "EasyTracker.h"
#import "GANTracker.h"
#import "FlurryAnalytics.h"

@class ActivityIndicatorView;
@class TermsViewController;
@class PrivacyPolicyViewController;

@interface SignUpViewController : TrackedUIViewController <NSXMLParserDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *firstNameTextField,*phoneNumberTextField,*lastNameTextField,*emailTextField,*passWordTextField,*zipCodeTextField,*promocodeTextField;
@property (nonatomic, retain) IBOutlet UIButton *agreeCheckBox;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) NSMutableString *currentString,*signupResult;

@property (nonatomic, retain) IBOutlet UILabel *activeServer;

@property (nonatomic, retain) ActivityIndicatorView *activityindicatter;
@property (nonatomic, retain) TermsViewController *objTerms;
@property (nonatomic, retain) PrivacyPolicyViewController *objPrivacy;
@property (nonatomic, retain) AppDelegate * sharedDelegate;


@property CGFloat shiftForKeyboard;
@property(nonatomic,retain)NSMutableData *webData;

-(IBAction)agreeCheckBoxButtonClicked:(id)sender;
-(IBAction)privacyPolicyButtonClicked:(id)sender;
-(IBAction)termsOfUseButtonClicked:(id)sender;

-(IBAction)signUpButtonClicked:(id)sender;
- (BOOL) validatePhoneNumber: (NSString *) candidate ;
-(BOOL) isPasswordValid:(NSString *)pwd;
//-(IBAction)returnClicked:(id)sender;
-(IBAction)backgroundClicked:(id)sender;
- (BOOL) validateEmail: (NSString *) candidate;
-(BOOL)valideZipcode:(NSString *)candidate;


-(IBAction)back:(id)sender;

- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
