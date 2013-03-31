//
//  AppDelegate.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "defines.h"
#import "FlurryAnalytics.h"
#import <CommonCrypto/CommonHMAC.h>
#import "MyCLLocation.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "CheckinViewController.h"
//#import <FacebookSDK/FacebookSDK.h>

@class ViewController;
@class MyCLLocation;
@class Reachability;
@class FlurryAnalytics;
@class CheckinViewController;

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,NSXMLParserDelegate,MyCLLocationDelegate,MKReverseGeocoderDelegate>

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) Reachability *internetReach;
@property (retain, nonatomic) ViewController *viewController;
@property (retain, nonatomic) MyCLLocation *myLocation;
@property (nonatomic, retain) NSMutableDictionary *nearMeDetailDict;
@property (nonatomic, retain) NSUserDefaults *searchingradies,*userdetails;
@property (nonatomic, retain) NSString *versionString;
@property (nonatomic) BOOL isProduction,isAttended,isNotAttended;
@property (nonatomic, retain) CheckinViewController *checkinViewCtrl;
@property (nonatomic, assign) NSMutableString *currentelement,*currentDateString;
@property (nonatomic, retain) NSString *urlActionController;
@property (nonatomic, retain) NSString *urlAction;
@property (nonatomic, retain) NSMutableDictionary *urlActionParameters;
@property (nonatomic, retain) NSString *activeServerUrl;
@property (nonatomic, retain) NSString *currentZipCode;
@property (nonatomic, retain) NSString *currentLatLon;

//@property (strong, nonatomic) FBSession *session;


@property BOOL myOffersUpdate,isLocationUpdate,isSelectedDisButton,isSignout,nearmedidSele,updateSearch,updateNearme,isNotReachable,isExits;

- (void) parseXML:(NSString *) xmlString;

- (NSString *) currentServer: (NSString *) title;

- (void) setCurrentDate;


@end
