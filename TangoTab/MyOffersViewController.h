//
//  MyOffersViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




#import "defines.h"
#import "ActivityIndicatorView.h"
#import "MyOffersMapViewController.h"
#import "ASIHTTPRequest.h"
#import "CheckinViewController.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "MyOffersTableviewCell.h"
#import "EasyTracker.h"
#import "GANTracker.h"
#import "OverlayViewController.h"
#import "Base64.h"



@class ActivityIndicatorView;
@class MyOffersTableviewCell;
@class ASINetworkQueue;
@class OverlayViewController;
@class CheckinViewController;
@class MyOffersMapViewController;



@interface MyOffersViewController : TrackedUIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
    int pageIndex;
    int noOfOffers;
    UIButton *showMore;
}

@property (nonatomic, retain) IBOutlet UITableView *myOfferTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *map_button;
@property (nonatomic, retain) IBOutlet UISearchBar *myDealsSearchBar;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property(nonatomic,retain)NSMutableString *deal_name,*isconsumershownup,*host_manager_emailid,*deal_description,*deal_restrictions,*start_time,*end_time,*business_name,*reserved_time_stamp,*address,*image_url,*noOfdeals,*currentElement,*deal_id,*deal_manager_emailid,*con_res_id,*longitude,*latitude,*current_date;
@property(nonatomic,retain)NSMutableDictionary *Details;
@property(nonatomic,retain)UILabel *nodeals_Lable;

@property (nonatomic, retain) NSString *serverURL,*passwordStringEncoded;
@property (nonatomic, retain) NSMutableArray *myOffersArray;

@property (nonatomic, assign) OverlayViewController *overlayview;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) CheckinViewController *checkView;
@property (nonatomic, retain) AppDelegate *appdelegate;
@property (nonatomic, retain) MyOffersMapViewController *mapviewcontroller;
@property (nonatomic, retain) IBOutlet MyOffersTableviewCell *customtableviewcell;

//Search Bar

@property (nonatomic, retain) NSMutableArray *searchingArray,*cMyDealsArray;
@property (nonatomic, assign) BOOL searching,letUserSelectRow;
@property BOOL failed;


-(IBAction)mapButton_Action:(id)sender;
-(void) parseXML:(NSString *) xmlString;
-( void) sendASIHTTPRequest:(NSURL*)serverURLs;
- (void)showActivityIndicatorView;
-(void)stopActivityIndicatorView;
- (void) searchTableView;
-(void)displayTableView;


@end
