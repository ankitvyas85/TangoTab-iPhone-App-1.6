//
//  PlacesViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "PlacesXmlParser.h"
#import "LocationController.h"
#import "EasyTracker.h"

@class PlacesTableViewCell,OverlayViewController, ActivityIndicatorView;
@interface PlacesViewController : TrackedUIViewController<LocationControllerDelegate> {

	IBOutlet PlacesTableViewCell *placesTableViewCell;
	IBOutlet UITableView *placesTableView;
	UISegmentedControl *segmentedControl;
	
	NSMutableArray *copyPlacesArray;
	IBOutlet UISearchBar *placesSearchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	OverlayViewController *ovController;
	
	LocationController *locationController;
	NSMutableArray *searchTempArray;
	
	ActivityIndicatorView *activityIndicatorView;
	UIBarButtonItem *mapButton;
	
	NSMutableArray *elementStack;
	PlacesXmlParser *placesParser;
	
	NSMutableArray *placesArray;
	
	BOOL isFirstLoaded;
	
	UILabel *noDataLabel;
	
	NSString *lastSeenTimeStampString;
	NSString *serviceURL;
    
	NSNumber *searchingRadius;
    
    NSArray *addressArray;
}

@property(nonatomic, retain) IBOutlet PlacesTableViewCell *placesTableViewCell;
@property(nonatomic, retain) IBOutlet UITableView *placesTableView;
@property(nonatomic, retain) UISegmentedControl *segmentedControl;
@property(nonatomic, retain) NSString *serviceURL;
@property(nonatomic, retain) NSMutableArray *copyPlacesArray;
@property(nonatomic, retain) IBOutlet UISearchBar *placesSearchBar;
@property(nonatomic, assign) BOOL searching;
@property(nonatomic, assign) BOOL letUserSelectRow;
@property(nonatomic, retain) OverlayViewController *ovController;

@property(nonatomic, retain) LocationController *locationController;
@property(nonatomic, retain) NSMutableArray *searchTempArray;

@property(nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) UIBarButtonItem *mapButton;

@property(nonatomic,retain) NSMutableArray *elementStack;
@property(nonatomic,retain) PlacesXmlParser *placesParser;
@property(nonatomic, retain) NSMutableArray *placesArray;
@property(nonatomic, retain) NSString *lastSeenTimeStampString;
@property(nonatomic, retain) UILabel *noDataLabel;
@property(nonatomic, retain) NSNumber *searchingRadius;
@property(nonatomic, retain) NSArray *addressArray;

- (void)account_for_empty_results;
- (void)searchTableView;
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;

@end
