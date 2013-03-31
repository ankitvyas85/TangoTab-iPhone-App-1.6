//
//  WantItViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WantItXmlParser.h"
#import "AsyncImageView.h"
#import "EasyTracker.h"

@class ActivityIndicatorView;

@interface WantItViewController : TrackedUIViewController<UIActionSheetDelegate/*,UIPickerViewDelegate,UIPickerViewDataSource*/> {

	IBOutlet UILabel *restaurantNameLabel;
	IBOutlet UILabel *restaurantLocationLabel;
	IBOutlet UILabel *dealNameLabel;
	IBOutlet UILabel *creditValueLabel;
	IBOutlet UILabel *cuisineTypeIdLabel;
	IBOutlet UILabel *dateAndTimeLabel;
	IBOutlet UIButton *dealTimeButton;
	IBOutlet UILabel *dealDescriptionLabel;
	IBOutlet UILabel *dealRestriction;
	IBOutlet AsyncImageView *myImageView;
	UIActionSheet *dateActionSheet;
	UIPickerView *datePicker;
	
	NSMutableDictionary *wantItDic;
	NSMutableArray *reviewsArray;
	
	NSDateFormatter* df;
	BOOL isDateInMiddle;
	
	NSMutableArray *elementStack1;
	WantItXmlParser *wantItXmlParser;
	
	NSMutableArray *resultArray;
	
	NSDateFormatter *resultDate;
	
	NSString *resultDateString;
	
	NSURL *imageURL;
	
	IBOutlet UITextField *emailTextField;
	
	BOOL isFirstFromPlaces;
//	UITextField	*passwordTextField;
	CGFloat shiftForKeyboard;
	
	UITextField *referalEmailId;
	
	ActivityIndicatorView *activityIndicatorView;
	UIBarButtonItem *reviewsButton;
}
@property(nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *restaurantLocationLabel;
@property(nonatomic, retain) IBOutlet UILabel *dealNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *creditValueLabel;
@property(nonatomic, retain) IBOutlet UILabel *cuisineTypeIdLabel;
@property(nonatomic, retain) IBOutlet UIButton *dealTimeButton;
@property(nonatomic, retain) IBOutlet UILabel *dateAndTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel *dealDescriptionLabel;
@property(nonatomic, retain) IBOutlet UILabel *dealRestriction;
@property(nonatomic, retain) IBOutlet AsyncImageView *myImageView;
@property(nonatomic, retain) NSMutableDictionary *wantItDic;
@property(nonatomic, retain) NSMutableArray *reviewsArray;
@property(nonatomic, retain) NSMutableArray *elementStack1;
@property(nonatomic, retain) WantItXmlParser *wantItXmlParser;
@property(nonatomic, retain) NSString *resultDateString;
@property(nonatomic, retain) NSURL *imageURL;
@property(nonatomic, retain) UIPickerView *datePicker;
@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, assign) BOOL isFirstFromPlaces;
@property(nonatomic, retain) UITextField *referalEmailId;
@property(nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) UIBarButtonItem *reviewsButton;
@property CGFloat shiftForKeyboard;
/*
-(IBAction)changeDateButtonClicked:(id)sender;
 */
-(IBAction)fixDealButtonClicked:(id)sender;
-(IBAction)shareItButtonClicked:(id)sender;
-(IBAction)mapButtonClicked:(id)sender;
/*
-(IBAction)textFieldReturnClicked;
 */
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
