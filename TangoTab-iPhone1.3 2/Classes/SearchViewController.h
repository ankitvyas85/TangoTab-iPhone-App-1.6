//
//  SearchViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchXmlParser.h"
#import "SearchLocationController.h"
#import "ActivityIndicatorView.h"
#import "EasyTracker.h"

@class SearchTableViewCell;
@interface SearchViewController : TrackedUIViewController<SearchLocationControllerDelegate> {
	IBOutlet UISearchBar *restaurantSearchBar;
	IBOutlet UISearchBar *locationSearchBar;
	IBOutlet UITableView *searchTableView;
	
	NSMutableArray *searchArray;
	SearchXmlParser *searchXmlParser;
	NSMutableArray *elementStack;
	IBOutlet SearchTableViewCell *objSearchTableViewCell;
	
	SearchLocationController *myCLController;

	ActivityIndicatorView *activityIndicatorView;
	
	UILabel *noDataLabel;
	
	BOOL isResSearchBarResign;
	BOOL isLocSearchBarResign;
}
@property(nonatomic,retain) UISearchBar *restaurantSearchBar;
@property(nonatomic,retain) UISearchBar *locationSearchBar;
@property(nonatomic,retain) IBOutlet UITableView *searchTableView;

@property(nonatomic,retain) NSMutableArray *searchArray;
@property(nonatomic,retain) SearchXmlParser *searchXmlParser;
@property(nonatomic,retain) NSMutableArray *elementStack;
@property(nonatomic,retain) SearchLocationController *myCLController;
@property(nonatomic,retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain) UILabel *noDataLabel;
@property(nonatomic,assign) BOOL isResSearchBarResign;
@property(nonatomic,assign) BOOL isLocSearchBarResign;
- (void)account_for_empty_results;
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
@end
