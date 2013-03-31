//
//  AddReviewViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
#import "CheckInXmlParser.h"
@class ActivityIndicatorView;
@interface AddReviewViewController : TrackedUIViewController<UITextViewDelegate> {

	IBOutlet UIImageView *image1;
	IBOutlet UIImageView *image2;
	IBOutlet UIImageView *image3;
	IBOutlet UIImageView *image4;
	IBOutlet UIImageView *image5;
	
	IBOutlet UIImageView *image;
	
	int rating;
	
	IBOutlet UITextView *textView1;
	IBOutlet UILabel *restaurantNameLabel;
	UIBarButtonItem *sendButton;
	UIBarButtonItem *doneButton;
	
	NSMutableDictionary *dealDic;
	
	NSMutableArray *elementStack;
	
	CheckInXmlParser *checkInXmlParser;
	
	ActivityIndicatorView *activityIndicatorView;
}
@property(nonatomic, retain) IBOutlet UIImageView *image1;
@property(nonatomic, retain) IBOutlet UIImageView *image2;
@property(nonatomic, retain) IBOutlet UIImageView *image3;
@property(nonatomic, retain) IBOutlet UIImageView *image4;
@property(nonatomic, retain) IBOutlet UIImageView *image5;
@property(nonatomic, retain) IBOutlet UIImageView *image;
@property(nonatomic, retain) IBOutlet UITextView *textView1;
@property(nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property(nonatomic, retain) UIBarButtonItem *sendButton;
@property(nonatomic, retain) UIBarButtonItem *doneButton;
@property(nonatomic, retain) NSMutableArray *elementStack;
@property(nonatomic, retain) CheckInXmlParser *checkInXmlParser;
@property(nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) NSMutableDictionary *dealDic;

-(void)stopActivityIndicatorView;
- (void)showActivityIndicatorView;
@end
