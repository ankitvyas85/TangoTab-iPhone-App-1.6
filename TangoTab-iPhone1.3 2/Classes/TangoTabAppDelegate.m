//
//  TangoTabAppDelegate.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 09/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TangoTabAppDelegate.h"
#import "MyDealsNavigationController.h"
#import "SettingsViewController.h"
#import "PlacesNavigationController.h"
#import "SettingsNavigationController.h"
#import "EasyTracker.h"
#import "defines.h"

/* Changes made to enable full view of Banner*/
/* 11/03/2011
@interface UINavigationBar (MyCustomNavBar)
@end
@implementation UINavigationBar (MyCustomNavBar)
- (void) drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"AppBanner320X44.png"];
    [barImage drawInRect:rect];
}
@end
*/
/* 11/03/2011*/
@interface UINavigationBar (MyCustomNavBar)
@end
@implementation UINavigationBar (MyCustomNavBar)
- (void) drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"tango.png"];
    [barImage drawInRect:rect];
}
@end


@implementation TangoTabAppDelegate

//Gopal 
@synthesize userValidationParser;
@synthesize prefs;

@synthesize window,navigationController,objTabBarController;
@synthesize isConnTimeOut;
@synthesize placesLastSeenTimeStamp,myDealsLatSeenTimeStamp;
@synthesize isFromWantIt;
@synthesize wantItDic;
@synthesize isFromSearch;
@synthesize wantToGoBack;
@synthesize isAddressForSearch;
@synthesize isGoBackToplaces;
@synthesize isWantToPopInMap;
@synthesize userInfoDic;
@synthesize isUserLogedIn;
@synthesize isWantToGoBackInMyDeals;
@synthesize currentLocation;
@synthesize isDealsWithLocationInPlaces;
@synthesize settingsDict;
@synthesize settingsController;
@synthesize placesController;
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [EasyTracker launchWithOptions:launchOptions
                    withParameters:nil
                         withError:nil];
    
    [window makeKeyAndVisible];
    [self animateSplashScreen];
    prefs = [NSUserDefaults standardUserDefaults];

    // to avoid keyboard popping up while splash fades out, delay has been added, and actual app launch with this slight delay.
    [self performSelector:@selector(launchAppAfterSplash) withObject:self afterDelay:1.0];
    
    return YES;
}

-(void)launchAppAfterSplash
{
    [objTabBarController setSelectedIndex:3];
    
	[objTabBarController.view setFrame:CGRectMake(0, 0, 480, 460)];
	
    
//	UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
//	[titleView setImage:[UIImage imageNamed:@"AppBanner320x44.png"]]; 
    // the previously used banner was: TangoT_banner_320x44.jpg, it has been retained in this project in case of future reference.
    objTabBarController.navigationItem.rightBarButtonItem = nil;
    objTabBarController.navigationItem.leftBarButtonItem = nil;

	//[objTabBarController.navigationItem setTitleView:titleView];
	//[titleView release];
	userInfoDic = [[NSMutableDictionary alloc] init];
    
	navigationController = [[UINavigationController alloc] initWithRootViewController:objTabBarController];
	[self.navigationController.navigationBar setHidden:YES];
	//[navigationController.navigationBar setTintColor:[UIColor whiteColor]];
	[window addSubview:navigationController.view];
	isConnTimeOut = NO;
	isFromWantIt = NO;
	isFromSearch = NO;
	wantToGoBack = NO;
	isGoBackToplaces = NO;
	isAddressForSearch = NO;
	isWantToPopInMap = NO;
	isUserLogedIn = NO;
	isWantToGoBackInMyDeals = NO;
	isDealsWithLocationInPlaces = NO;
	
	//Creation of plist file
	if(![fm fileExistsAtPath:
		 [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
		  stringByAppendingPathComponent:@"settings.plist"]])
	{
		[fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"] toPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"bookMark.plist"] error:nil];
	}
    
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];
    NSString *mydictpath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    
    self.settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
    
    if (! self.settingsDict) { //default values
        self.settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
        [self.settingsDict setValue:@"" forKey:@"username"];
        [self.settingsDict setValue:@"" forKey:@"password"];
        [self.settingsDict setValue:[NSNumber numberWithBool:NO] forKey:@"userloggedin"];
        [self.settingsDict setValue:@"" forKey:@"lastSeenDate"];
        [self.settingsDict setValue:@"" forKey:@"myDealsLastSeenDate"];
        [self.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"autoCheckIn"];
        [self.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"pushNotification"];
        [self.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"facebook"];
        [self.settingsDict setValue:[NSNumber numberWithBool:YES] forKey:@"twitter"];
        [self.settingsDict setValue:[NSNumber numberWithDouble:10.0] forKey:@"searchingradius"]; //10 miles
        [self.settingsDict writeToFile:mydictpath atomically:YES];
        
        [self saveObject:settingsDict];
    }
    
    if ([[self.settingsDict valueForKey:@"autoCheckIn"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        isUserLogedIn = [[self.settingsDict valueForKey:@"userloggedin"] boolValue];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *myString = [prefs stringForKey:@"username"];
    if ([myString length]> 0) {
       // [settingsController user_validation:nil];
        NSString *passwordString = [prefs valueForKey:@"password"];
        NSString *userName= [prefs valueForKey:@"username"];
        NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",SERVER_URL,userName,passwordString];	
        [userValidationParser loadFromURL:serviceURL];
        [objTabBarController setSelectedIndex:2];
        isUserLogedIn = YES;
    }
    
    self.settingsController.settingsDict = [self.settingsDict mutableCopy];
    self.placesController.searchingRadius = [self.settingsDict objectForKey:@"searchingradius"];
    
    self.settingsController.delegate = self;    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark -
#pragma mark UserSettingsDelegate

- (void)saveObject:(id)object
{
    self.settingsDict = [object mutableCopy];
    
    //NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];
                              
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    
    [self.settingsDict writeToFile:filePath atomically:YES];

    
    self.placesController.searchingRadius = [self.settingsDict objectForKey:@"searchingradius"];
    self.placesController.placesParser.searchingRadius = [self.settingsDict objectForKey:@"searchingradius"];
}

- (void) animateSplashScreen
{
    
    //fade time
   // CFTimeInterval animation_duration = 2.5;
    
    //SplashScreen
    UIImageView * splashView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)]autorelease];
    splashView.image = [UIImage imageNamed:@"splash@2x.png"];
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
    
    //Animation (fade away with zoom effect)
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:animation_duration];
//    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
//    [UIView setAnimationDelegate:splashView];
//    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
//    splashView.alpha = 0.0;
//    splashView.frame = CGRectMake(-60, -60, 440, 600);
//    
//    [UIView commitAnimations];
    
}



- (void)dealloc {

	[currentLocation release];
	[wantItDic release];
	[userInfoDic release];
	[placesLastSeenTimeStamp release];
	[myDealsLatSeenTimeStamp release];
	[objTabBarController release];
    [window release];
	[navigationController release];
    //[searchingRadius release];
    [settingsDict release];
    [settingsController release];
    
    [super dealloc];
}


@end
