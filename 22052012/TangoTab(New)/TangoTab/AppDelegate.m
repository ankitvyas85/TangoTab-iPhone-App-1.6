//
//  AppDelegate.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "HeaderFiles.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize nearMeDetailDict,myOffersUpdate,searchingradies,isLocationUpdate,tabController,isSelectedDisButton,userdetails,internetReach,versionString;
@synthesize isSignout,nearmedidSele,updateSearch,updateNearme,isNotReachable,isExits;


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [nearMeDetailDict release];
    [userdetails release];
    [searchingradies release];
    [internetReach release];
    [super dealloc];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    tabController = [[UITabBarController alloc] init];
    nearMeDetailDict = [[NSMutableDictionary alloc] init];
    searchingradies=[NSUserDefaults standardUserDefaults];
   versionString = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
   
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"radies"]==nil) {
        [searchingradies setValue:@"50" forKey:@"radies"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"rememberSwitch"]==nil) {
        [searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
    }
    
    userdetails=[NSUserDefaults standardUserDefaults];
    isLocationUpdate = NO;
    isSelectedDisButton = NO;
    nearmedidSele = NO;
    myOffersUpdate = NO;
    isExits = NO;
    /* Google Analytics **/
    
    [EasyTracker launchWithOptions:launchOptions withParameters:nil withError:nil];
    
    internetReach = [Reachability reachabilityForInternetConnection] ;
	[internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
    switch (netStatus)
    {            
        case ReachableViaWWAN:
        {
            isNotReachable=NO;
            break;
        }
        case ReachableViaWiFi:
        {
            isNotReachable=NO;
            break;
        }
        case NotReachable:
        {
            isNotReachable=YES;
            //isExits = YES;
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //            [alert show];
            //            [alert release];
            break;
        }
            
    }

    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [nav setNavigationBarHidden:YES];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    internetReach = [Reachability reachabilityForInternetConnection] ;
	[internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
    switch (netStatus)
    {            
        case ReachableViaWWAN:
        {
            isNotReachable=NO;
            break;
        }
        case ReachableViaWiFi:
        {
            isNotReachable=NO;
            break;
        }
        case NotReachable:
        {
            isNotReachable=YES;
            //isExits = YES;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
            break;
        }
            
    }
    
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case ReachableViaWWAN:
        {
            isNotReachable=NO;
            break;
        }
        case ReachableViaWiFi:
        {
            isNotReachable=NO;
            break;
        }
        case NotReachable:
        {
            isNotReachable=YES;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
            break;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
