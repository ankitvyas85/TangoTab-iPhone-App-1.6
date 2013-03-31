//
//  MyDealsViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDealsXmlParser.h"
#import "ActivityIndicatorView.h"
#import "MyCLController.h"
#import "EasyTracker.h"

@class OverlayViewController,MyDealsTableviewCell;
@interface MyDealsViewController : TrackedUIViewController {

	IBOutlet UITableView *myDealsTableView;
	UISegmentedControl *segmentedControl;
	
	IBOutlet UISearchBar *myDealsSearchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	OverlayViewController *ovController;
	NSMutableArray *copyMyDealsArray;
	NSMutableArray *searchTempArray;
	
	NSMutableArray *elementStack;
	MyDealsXmlParser *myDealsParser;
	NSString *serviceURL;
	
	NSMutableArray *myDealsArray;
	
	UIBarButtonItem *mapButton;
	ActivityIndicatorView *activityIndicatorView;

	BOOL isFirstLoaded;
	
	MyCLController *myCLController;
	NSString *zipCode;
	
	IBOutlet MyDealsTableviewCell *objMyDealsTableViewCell;
	
	UILabel *noDataLabel;

}
@property(nonatomic, retain) IBOutlet UITableView *myDealsTableView;
@property(nonatomic,retain) UISegmentedControl *segmentedControl;

@property(nonatomic,retain) IBOutlet UISearchBar *myDealsSearchBar;
@property(nonatomic,assign) BOOL searching;
@property(nonatomic,assign) BOOL letUserSelectRow;
@property(nonatomic,retain) OverlayViewController *ovController;
@property(nonatomic,retain) NSMutableArray *copyMyDealsArray;
@property(nonatomic,retain) NSMutableArray *searchTempArray;

@property(nonatomic,retain) NSMutableArray *elementStack;
@property(nonatomic,retain) MyDealsXmlParser *myDealsParser;
@property(nonatomic,retain) NSString *serviceURL;
@property(nonatomic,retain) NSMutableArray *myDealsArray;

@property(nonatomic,retain) UIBarButtonItem *mapButton;
@property(nonatomic,retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain) MyCLController *myCLController;
@property(nonatomic,retain) UILabel *noDataLabel;

- (void)account_for_empty_results;
- (void) searchTableView;

- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
