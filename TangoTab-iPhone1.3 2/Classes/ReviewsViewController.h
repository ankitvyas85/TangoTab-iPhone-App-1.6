//
//  ReviewsViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewsXmlParser.h"
#import "EasyTracker.h"
@class ActivityIndicatorView,ReviewTableViewCell;

@interface ReviewsViewController : TrackedUIViewController {

	
	IBOutlet UITableView *reviewTableView;
	NSMutableArray *reviewsArray;
	
	NSMutableArray *elementStack;
	ReviewsXmlParser *reviewsXmlParser;
	NSString *serviceURL;
	NSMutableDictionary *dealDic;
	ActivityIndicatorView *activityIndicatorView;
	IBOutlet ReviewTableViewCell *objReviewTableViewCell;
	int rating;
	
	UIBarButtonItem *addReview;
	
	UILabel *noDataLabel;
}
@property(nonatomic,retain) IBOutlet UITableView *reviewTableView;
@property(nonatomic,retain) NSMutableArray *reviewsArray;
@property(nonatomic,retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain) NSMutableDictionary *dealDic;
@property(nonatomic,retain) UIBarButtonItem *addReview;
@property(nonatomic,retain) UILabel *noDataLabel;
- (void)account_for_empty_results;
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
