//
//  ForgetPasswordViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "defines.h"
#import "ActivityIndicatorView.h"
#import "HeaderFiles.h"
#import "AppDelegate.h"


@interface ForgetPasswordViewController : TrackedUIViewController <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *tempdic;
@property (nonatomic, retain) NSString *currentelement;
@property (nonatomic, retain) NSMutableString *password,*success,*phonenumber;

@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UITextField *emailText;

-(NSMutableDictionary *) smlParser;
-(IBAction)send:(id)sender;
-(IBAction)Cancel:(id)sender;
- (BOOL) validateEmail: (NSString *) candidate;

@end
