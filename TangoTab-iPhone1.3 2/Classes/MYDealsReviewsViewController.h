//
//  MYDealsReviewsViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDealsReviewsXmlParser.h"
#import "EasyTracker.h"
@class ActivityIndicatorView,MYDealsReviewsTableViewControllerCell;

@interface MYDealsReviewsViewController : TrackedUIViewController {


	IBOutlet UITableView *reviewTableView;
	NSMutableArray *reviewsArray;
	
	NSMutableArray *elementStack;
	MyDealsReviewsXmlParser *myDealsReviewsXmlParser;
	NSString *serviceURL;
	NSMutableDictionary *dealDic;
	ActivityIndicatorView *activityIndicatorView;
	IBOutlet MYDealsReviewsTableViewControllerCell *objReviewTableViewCell;
	int rating;
	
	UILabel *noDataLabel;
}
@property(nonatomic,retain) IBOutlet UITableView *reviewTableView;
@property(nonatomic,retain) NSMutableArray *reviewsArray;
@property(nonatomic,retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain) NSMutableDictionary *dealDic;
@property(nonatomic,retain) MyDealsReviewsXmlParser *myDealsReviewsXmlParser;
@property(nonatomic,retain) UILabel *noDataLabel;
- (void)account_for_empty_results;
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end

		
	