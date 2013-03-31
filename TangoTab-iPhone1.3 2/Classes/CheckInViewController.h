//
//  CheckInViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckInXmlParser.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "EasyTracker.h"

@class ActivityIndicatorView;
@interface CheckInViewController : TrackedUIViewController<SA_OAuthTwitterEngineDelegate,SA_OAuthTwitterControllerDelegate,UITextViewDelegate,FBRequestDelegate,FBDialogDelegate,FBSessionDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
	IBOutlet FBLoginButton* _fbButton;
	Facebook* _facebook;
	NSArray* _permissions;
	IBOutlet UITextView *textView;
	
	NSMutableArray *elementStack;
	
	CheckInXmlParser *checkInXmlParser;
	
	
	NSMutableDictionary *dealDic;
	SA_OAuthTwitterEngine *_engine;
	
	NSString *availableDate;
	
	ActivityIndicatorView *activityIndicatorView;
}
@property(nonatomic, retain)IBOutlet UITextView *textView;
@property(nonatomic, retain) NSMutableArray *elementStack;
@property(nonatomic, retain) CheckInXmlParser *checkInXmlParser;
@property(nonatomic, retain) NSMutableDictionary *dealDic;
@property(nonatomic, retain) NSString *availableDate;
@property(nonatomic, retain) ActivityIndicatorView *activityIndicatorView;

-(IBAction)facebookButtonClicked:(id)sender;
-(IBAction)twitterButtonClicked:(id)sender;
- (IBAction) publishStream;

-(IBAction)sendSms:(id)sender;
-(IBAction)sendMail:(id)sender;

- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;

-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

-(void)displaySMSComposerSheet;
@end
