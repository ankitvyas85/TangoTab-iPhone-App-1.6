//
//  AppDelegate.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "FlurryAnalytics.h"
#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "defines.h"
#import "ActivityIndicatorView.h"

NSString * const NotifyUrlAction = @"ttapurlnotify";
NSString * const NotifyProcessLocalNotifcations = @"ttprocesslocalnotify";

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize nearMeDetailDict,myOffersUpdate,searchingradies,isLocationUpdate,isSelectedDisButton,userdetails,internetReach,versionString;
@synthesize isSignout,nearmedidSele,updateSearch,updateNearme,isNotReachable,isExits,isProduction,myLocation;
@synthesize checkinViewCtrl,isAttended,isNotAttended;
@synthesize currentDateString,currentelement;
@synthesize urlAction, urlActionController, urlActionParameters, activeServerUrl, currentZipCode, currentLatLon;


NSString *const FBSessionStateChangedNotification = @"com.tangotab.Login:FBSessionStateChangedNotification";

//@synthesize session = _session;

- (NSString *) currentServer: (NSString *) title {
    NSString *result = @"";
    if ([activeServerUrl isEqualToString: STAGE_SERVER] )
        result = @"STAGE";
    else
    if ([activeServerUrl isEqualToString: QA_SERVER] )
        result = @"QA";
    else
    if ([activeServerUrl isEqualToString: DEVEL_SERVER] )
        result = @"DEVEL";
    if ([result isEqualToString:@""])
        result = title;
    else {
        title = [title stringByAppendingString:@" "];
        title = [title stringByAppendingString: result];
        result = title;
    }
    return result;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if (!url) {  return NO; }
    
    NSString *encodedString = [url absoluteString];
    debug_NSLog(@"openURL: %@",encodedString);
 
    // ttapp://deal/dealId/date
    // ttapp://deal/dealId/date/spMailingId/spUserId/spJobId
    // ttapp://search/city
    // ttapp://search/city/spMailingId/spUserId/spJobId
    // ttapp://nearMe
    // ttapp://nearMe/spMailingId/spUserId/spJobId
    self.urlActionController = @"";
    if ([encodedString hasPrefix: @"ttapp"])
    {
        NSMutableArray *urlParse = (NSMutableArray *)[encodedString componentsSeparatedByString: @"/"];
        if ([urlParse count] == 5 || [urlParse count] == 8)
        {
            NSString *controller = [urlParse objectAtIndex: 2];
 
            if ([controller isEqualToString:@"deal"])
            {
                self.urlActionController = @"searchViewController";
                self.urlAction = @"deal";
                self.urlActionParameters = [[ NSMutableDictionary alloc] init];
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 3] forKey:@"dealId"];
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 4] forKey:@"date"];
                [self.urlActionParameters setObject:@"NO" forKey:@"clickOccured"];
                if ([urlParse count] == 8)
                {
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 5] forKey:@"spMailingId"];
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 6] forKey:@"spUserId"];
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 7] forKey:@"spJobId"];
                }
            }
        }
        else
        if ([urlParse count] == 4 || [urlParse count] == 7)
        {
            NSString *controller = [urlParse objectAtIndex: 2];
            if ([controller isEqualToString:@"search"])
            {
                self.urlActionController = @"searchViewController";
                self.urlAction = @"search";
                self.urlActionParameters = [[ NSMutableDictionary alloc] init];
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 3] forKey:@"city"];
                if ([urlParse count] == 7)
                {
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 4] forKey:@"spMailingId"];
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 5] forKey:@"spUserId"];
                    [self.urlActionParameters setObject:[urlParse objectAtIndex: 6] forKey:@"spJobId"];
                }

             }
         }
        else
        if ([urlParse count] == 3 || [urlParse count] == 6)
        {
            self.urlActionController = @"nearMeViewController";
            self.urlAction = @"nearMe";
            self.urlActionParameters = [[ NSMutableDictionary alloc] init];
            if ([urlParse count] == 6)
            {
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 3] forKey:@"spMailingId"];
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 4] forKey:@"spUserId"];
                [self.urlActionParameters setObject:[urlParse objectAtIndex: 5] forKey:@"spJobId"];
            }
        }
     
    }
    else  // handle Facebook login callback
    {
        [FBSession.activeSession handleOpenURL:url];
        debug_NSLog(@"FB Auth Token: %@",FBSession.activeSession.accessToken);

    }
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [nearMeDetailDict release];
    [userdetails release];
    [searchingradies release];
    [internetReach release];
    [checkinViewCtrl release];
    [super dealloc];
}

#pragma mark Uncaught exception handler

void uncaughtExceptionHandler(NSException *exception)
{
    
    if ([exception respondsToSelector:@selector(callStackSymbols)]) {
        
        NSLog(@"Recording summarized exception %@ with callStack %@", exception, [exception callStackSymbols]);
        
        NSMutableString *summarizedCallStackSymbols = [NSMutableString string];
        
        for (NSString *callStackSymbol in [exception callStackSymbols]) {
            
            /* Remove the framework prefix */
            if (callStackSymbol.length > 51)
                
                callStackSymbol = [callStackSymbol substringFromIndex:51];
            
            /* Flurry's message space is very limited; remove the offset to further save space */
            NSRange plusRange = [callStackSymbol rangeOfString:@" + "];
            
            if (plusRange.location != NSNotFound)
                
                callStackSymbol = [callStackSymbol substringToIndex:plusRange.location];
            
            /* Skip useless top-of-stack entries */
            if (([callStackSymbol rangeOfString:@"__exceptionPreprocess"].location != NSNotFound) ||
                
                ([callStackSymbol rangeOfString:@"objc_exception_throw"].location != NSNotFound))
                
                continue;
            
            /* We could add a character between each symbol, but that just loses us precious space */
            [summarizedCallStackSymbols appendFormat:@"%@", callStackSymbol]; 
            
        }
        [FlurryAnalytics logError:[exception name]
         
                          message:summarizedCallStackSymbols
         
                        exception:exception]; 
        
    } else {
        
        [FlurryAnalytics logError:[exception name]
         
                          message:[exception reason]
         
                        exception:exception]; 
        
    }
}


- (void) setCurrentDate {
    
    NSString *getCurrentDateURL = self.activeServerUrl;
    
    getCurrentDateURL = [getCurrentDateURL stringByAppendingString: @"/mydeals/getCurrentDate"];
    [self parseXML:getCurrentDateURL];
    
}

- (void)locationUpdate:(CLLocation *)location
{
    NSString *lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    self.currentLatLon = @"";
    
    self.currentLatLon = [self.currentLatLon stringByAppendingString:lat];
    self.currentLatLon = [self.currentLatLon stringByAppendingString:@","];
    self.currentLatLon = [self.currentLatLon stringByAppendingString:lon];
    
   
    
    if (NSClassFromString(@"CLGeocoder")){
        CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                self.currentZipCode = placemark.postalCode;
                debug_NSLog(@"current ZipCode SET = %@", self.currentZipCode);

            }
            else if (error == nil &&[placemarks count] == 0){
            }
            else if (error != nil){
            } }];
    }
    else {
        MKReverseGeocoder *reverseGeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
        reverseGeoCoder.delegate = self;
        [reverseGeoCoder start];
    }
    [myLocation stop];
}

- (void)locationError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"Your device is configured to deny Location Services to TangoTab. Some features of TangoTab require these services to work. Please enable Location Services in the Settings App to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    [myLocation stop];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    @try {
 
        self.currentZipCode = placemark.postalCode;
        debug_NSLog(@"current ZipCode SET = %@", self.currentZipCode);
  //      [reverseGeoCoder cancel];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"Your device is configured to deny Location Services to TangoTab. Some features of TangoTab require these services to work. Please enable Location Services in the Settings App to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    
    myLocation = [[MyCLLocation alloc] init];
    myLocation.delegate = self;
    
    
    NSString *savedServerUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"activeServer"];
    if (savedServerUrl == nil)
        self.activeServerUrl = ACTIVE_SERVER_URL;
    else
         self.activeServerUrl = savedServerUrl;
    [self setCurrentDate];
    
    
    // Override point for customization after application launch.
    nearMeDetailDict = [[NSMutableDictionary alloc] init];
    searchingradies=[NSUserDefaults standardUserDefaults];
    isProduction = YES;
    isAttended=NO,isNotAttended = NO;
    

    if (!isProduction) {
        //TestServer
        [FlurryAnalytics startSession:@"L6HPY4GXMGZA4R9TFP11"];
    } else {
        //ProductionServer
        [FlurryAnalytics startSession:@"KYBU9TP2BC1CFK6HNCPK"];
    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //App installDate
    
    if([searchingradies objectForKey:@"installDate"] == 0){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss a"];
        NSDate *currDate = [dateFormatter dateFromString:currentDateString];
        NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
        [dateformstring setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
        NSString *resultDate = [dateformstring stringFromDate:currDate];
        NSDate *currDate1 = [dateformstring dateFromString:resultDate];
        [searchingradies setObject:currDate1 forKey:@"installDate"];
        [searchingradies synchronize];
    }
    
    
   versionString = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
   
    
    NSString *verString = [NSString stringWithFormat:@"%@",versionString];
    [FlurryAnalytics setVersion:[verString floatValue]];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"radies"]==nil) {
        [searchingradies setValue:@"10" forKey:@"radies"];
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
            
            break;
        }
            
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    

 //   self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    
    self.viewController = [[ViewController alloc] initWithNibName:@"EmailLoginView" bundle:[NSBundle mainBundle]];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [nav setNavigationBarHidden:YES];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
     return YES;
}




-(void) parseXML:(NSString *) xmlString
{
    @try {
        NSURL *url = [NSURL URLWithString:[xmlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *xmlData = [NSData dataWithContentsOfURL:url];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        [parser setDelegate:self];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
    }
    @catch (NSException *exception) {
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentelement=[[NSMutableString alloc]init];
    currentelement=[elementName mutableCopy];
    if ([elementName isEqualToString:@"Date"]) {
        currentDateString=[[NSMutableString alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentelement isEqualToString:@"Date"]) {
        [currentDateString appendString:terstring];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName { 
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
     NSLog(@"applicationWillResignActive:");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
 //   debug_NSLog(@"applicationWillEnterBackground and is being forced to exit so the LocalNotification are processed. FIX THIS");
 //   exit(0);
   
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground:");
    
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
           
            break;
        }
    }
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        // BUG: for the iOS 6 preview we comment this line out to compensate for a race-condition in our
        // state transition handling for integrated Facebook Login; production code should close a
        // session in the opening state on transition back to the application; this line will again be
        // active in the next production rev
  //      [self.session close]; // so we close our session and start over
         [FBSession.activeSession close];
    }
  
    
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
                                    FBLoggingBehaviorAccessTokens, FBLoggingBehaviorFBURLConnections, FBLoggingBehaviorSessionStateTransitions,
                                    nil]];
    
    if (self.urlActionController != nil && ![self.urlActionController isEqualToString:@""])
       [[NSNotificationCenter defaultCenter] postNotificationName:NotifyUrlAction object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotifyProcessLocalNotifcations object:nil];
    
    
    
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

            break;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate:");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [FBSession.activeSession close];
}

@end
