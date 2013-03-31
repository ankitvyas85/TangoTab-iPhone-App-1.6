//
//  TangoTabAppDelegate.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 09/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SettingsViewController.h"
#import "PlacesViewController.h"
#import "UserValidationParser.h"

@class UserValidationParser;
@class TabBarController;

@interface TangoTabAppDelegate : NSObject <UIApplicationDelegate, UserSettingsDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
	
	BOOL isConnTimeOut;
	
	NSFileManager *fm;
	
	IBOutlet UITabBarController *objTabBarController;

	NSString *placesLastSeenTimeStamp;
	NSString *myDealsLatSeenTimeStamp;
	
	BOOL isFromWantIt;
	
	NSMutableDictionary *wantItDic;

	BOOL isFromSearch;
	
	BOOL wantToGoBack;
	
	BOOL isWantToGoBackInMyDeals;
	
	BOOL isAddressForSearch;
	BOOL isGoBackToplaces;
	BOOL isWantToPopInMap;
	
	NSMutableDictionary *userInfoDic;
	
	BOOL isUserLogedIn;
	
	BOOL isDealsWithLocationInPlaces;
	CLLocation *currentLocation;
	//NSNumber *searchingRadius;
    NSMutableDictionary *settingsDict;
//	CLLocation *myDealsCurrentLocation;
    
    IBOutlet SettingsViewController *settingsController;
    IBOutlet PlacesViewController *placesController;
    

    

}

//Gopal 
@property (nonatomic, retain)    NSUserDefaults *prefs;
@property (nonatomic, retain) UserValidationParser *userValidationParser;
//Gopal
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, assign) BOOL isConnTimeOut;
@property (nonatomic, retain) IBOutlet UITabBarController *objTabBarController;
@property (nonatomic, retain) NSString *placesLastSeenTimeStamp;
@property (nonatomic, retain) NSString *myDealsLatSeenTimeStamp;
@property (nonatomic, assign) BOOL isFromWantIt;
@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, retain) NSMutableDictionary *wantItDic;
@property (nonatomic, assign) BOOL wantToGoBack;
@property (nonatomic, assign) BOOL isAddressForSearch;
@property (nonatomic, assign) BOOL isGoBackToplaces;
@property (nonatomic, assign) BOOL isWantToPopInMap;
@property (nonatomic, assign) BOOL isUserLogedIn;
@property (nonatomic, assign) BOOL isWantToGoBackInMyDeals;
@property (nonatomic, assign) BOOL isDealsWithLocationInPlaces;
@property (nonatomic, retain) NSMutableDictionary *userInfoDic;
@property (nonatomic, retain) CLLocation *currentLocation;
//@property (nonatomic, retain) NSNumber *searchingRadius;
@property (retain) NSMutableDictionary *settingsDict;
@property (nonatomic, retain) IBOutlet SettingsViewController *settingsController;
@property (nonatomic, retain) IBOutlet PlacesViewController *placesController;

-(void)animateSplashScreen;
-(void)launchAppAfterSplash;

@end

