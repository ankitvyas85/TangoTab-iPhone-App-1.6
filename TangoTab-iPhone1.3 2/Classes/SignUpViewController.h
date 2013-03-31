//
//  SignUpViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
@class SignUpXmlParser,ActivityIndicatorView;

@interface SignUpViewController : TrackedUIViewController {

	IBOutlet UITextField *firstNameTextField;
	IBOutlet UITextField *lastNameTextField;
	IBOutlet UITextField *emailTextField;
	IBOutlet UITextField *passWordTextField;
	IBOutlet UITextField *confirmPasswordTextField;
	IBOutlet UITextField *zipCodeTextField;
	IBOutlet UITextField *phoneNumberTextField;
	IBOutlet UIButton *agreeCheckBox;
	
	CGFloat shiftForKeyboard;
	
	NSMutableData *webData;
	SignUpXmlParser *signUpXmlParser;
	ActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passWordTextField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, retain) IBOutlet UITextField *zipCodeTextField;
@property (nonatomic, retain) IBOutlet UITextField *phoneNumberTextField;
@property (nonatomic, retain) IBOutlet UIButton *agreeCheckBox;
@property CGFloat shiftForKeyboard;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) SignUpXmlParser *signUpXmlParser;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;

-(IBAction)agreeCheckBoxButtonClicked:(id)sender;
-(IBAction)privacyPolicyButtonClicked:(id)sender;
-(IBAction)termsOfUseButtonClicked:(id)sender;
-(IBAction)signUpButtonClicked:(id)sender;
- (BOOL) validatePhoneNumber: (NSString *) candidate ;
-(BOOL) isPasswordValid:(NSString *)pwd;
-(IBAction)returnClicked:(id)sender;
-(IBAction)backgroundClicked:(id)sender;
- (BOOL) validateEmail: (NSString *) candidate;

- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
