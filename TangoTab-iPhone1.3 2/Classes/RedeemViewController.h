//
//  RedeemViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedeemXmlParser.h"
#import "AsyncImageView.h"
#import "EasyTracker.h"

@interface RedeemViewController : TrackedUIViewController {

	NSMutableDictionary *redeemDic;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *reservedIdLabel;
	IBOutlet UILabel *restNameLabel;
	IBOutlet UILabel *addressLabel;
	IBOutlet UILabel *cusionTypeLabel;
	IBOutlet UILabel *dealNameLabel;
	IBOutlet UILabel *dealDescriptionLabel;
	IBOutlet UILabel *restrictionLabel;
	IBOutlet UILabel *timeStampLabel;
	IBOutlet AsyncImageView *asyncImageView;
	
/*	
	NSMutableArray *elementStack;
	RedeemXmlParser *redeemXmlParser;
*/	
	IBOutlet UIButton *useDealBitton;
}
@property (nonatomic, retain) NSMutableDictionary *redeemDic;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *reservedIdLabel;
/*
@property (nonatomic, retain) NSMutableArray *elementStack;
@property (nonatomic, retain) RedeemXmlParser *redeemXmlParser;
 */
@property (nonatomic, retain) IBOutlet UIButton *useDealBitton;
@property (nonatomic, retain) IBOutlet AsyncImageView *asyncImageView;
@property (nonatomic, retain) IBOutlet UILabel *dealNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *restNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *cusionTypeLabel;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *dealDescriptionLabel;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *restrictionLabel;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *timeStampLabel;

//-(IBAction)markDealAsUsedButtonClicked:(id)sender;
-(IBAction)checkInButtonClicked:(id)sender;
//- (void)account_for_empty_results;
@end
