//
//  ShareItViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "CheckInXmlParser.h"
#import "EasyTracker.h"

@class ActivityIndicatorView;

@interface ShareItViewController : TrackedUIViewController <SA_OAuthTwitterEngineDelegate,SA_OAuthTwitterControllerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UITextViewDelegate,FBRequestDelegate,FBDialogDelegate,FBSessionDelegate> {
	IBOutlet FBLoginButton* _fbButton;
	Facebook* _facebook;
	IBOutlet UITextView *textView;
	NSArray* _permissions;
	SA_OAuthTwitterEngine *_engine;
	
	NSMutableArray *elementStack;
	CheckInXmlParser *checkInXmlParser;
	
	UITextField *emailTextField;
	
	NSMutableDictionary *dealDic;
	
	NSString *availableDate;
	ActivityIndicatorView *activityIndicatorView;

}
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) NSMutableArray *elementStack;
@property(nonatomic, retain) CheckInXmlParser *checkInXmlParser;
@property(nonatomic, retain) UITextField *emailTextField;
@property(nonatomic, retain) NSMutableDictionary *dealDic;
@property(nonatomic, retain) NSString *availableDate;
@property(nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) SA_OAuthTwitterEngine *_engine;
@property(nonatomic, retain) Facebook* _facebook;
@property(nonatomic, retain) IBOutlet FBLoginButton* _fbButton;

-(IBAction)sendMail:(id)sender;
-(void)canSendMail;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

-(IBAction)sendSms:(id)sender;
-(void)displaySMSComposerSheet;


-(IBAction)twitterButtonClicked:(id)sender;
-(IBAction)facebookButtonClicked:(id)sender;
- (IBAction) publishStream;

- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
