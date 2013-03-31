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

@class ViewController;
@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) Reachability *internetReach;
@property (retain, nonatomic) ViewController *viewController;

@property (nonatomic, retain) NSMutableDictionary *nearMeDetailDict;
@property (nonatomic, retain) NSUserDefaults *searchingradies;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) NSUserDefaults *userdetails;
@property (nonatomic, retain) NSString *versionString;


@property BOOL myOffersUpdate,isLocationUpdate,isSelectedDisButton,isSignout,nearmedidSele,updateSearch,updateNearme,isNotReachable,isExits;

@end
