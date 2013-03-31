//
//  ViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "EasyTracker.h"
#import "KeychainItemWrapper.h"
#import "defines.h"
#import "AppDelegate.h"
#import "ForgetPasswordViewController.h"

@class ForgetPasswordViewController;
@class ASIHTTPRequest;
@interface ViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tabview;
@property (nonatomic, retain) UITextField *userNameTextField,*passwordTextField;
@property (nonatomic, retain) NSArray *logArray;
@property (nonatomic, retain) UISwitch *rememberSwitch;
@property (nonatomic, retain) UIButton *forgetButton;
@property (nonatomic, retain) UITabBarItem *nearMeBarItem,*myOfferBarItem,*searchBarItem,*settingsBarItem;
@property (nonatomic, retain) NSMutableArray *userArray;
@property (nonatomic, retain) NSMutableDictionary *userDict;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableString *user_id,*first_name,*last_name,*zip_code,*mobile_phone,*count_Message;
@property BOOL failed;

@property (nonatomic, retain) AppDelegate *sharedDelegate;
@property (nonatomic, retain) ForgetPasswordViewController *forPasswordViewCtrl;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic,retain)  KeychainItemWrapper *keychain;


- (void) user_validation;
- (void) parseXML:(NSString *) xmlString;
//-(NSMutableDictionary *) smlParser : (NSString*)URL;
- (UITabBarController*)tabBarController;


@end
