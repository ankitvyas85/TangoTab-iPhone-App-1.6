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

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize nearMeDetailDict,myOffersUpdate,searchingradies,isLocationUpdate,isSelectedDisButton,userdetails,internetReach,versionString;
@synthesize isSignout,nearmedidSele,updateSearch,updateNearme,isNotReachable,isExits,isProduction,myLocation;
@synthesize checkinViewCtrl,isAttended,isNotAttended;
@synthesize checkinstatusmessage,currentelement;

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






- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
     [self parseXML:@"http://184.173.113.66/tangotabservices/services/mydeals/getCurrentDate"];
    // Override point for customization after application launch.
    nearMeDetailDict = [[NSMutableDictionary alloc] init];
    searchingradies=[NSUserDefaults standardUserDefaults];
    isProduction = NO;
    isAttended=NO,isNotAttended = NO;
    //myLocation = [[MyCLLocation alloc] init];

    if (!isProduction) {
        //TestServer
        [FlurryAnalytics startSession:@"L6HPY4GXMGZA4R9TFP11"];
    } else {
        //ProductionServer
        [FlurryAnalytics startSession:@"KYBU9TP2BC1CFK6HNCPK"];
    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
   
   versionString = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
   
    NSString *verString = [NSString stringWithFormat:@"%.1@",versionString];
    [FlurryAnalytics setVersion:[verString floatValue]];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"radies"]==nil) {
        [searchingradies setValue:@"10" forKey:@"radies"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"rememberSwitch"]==nil) {
        [searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"autocheckin"] == nil) {
        [searchingradies setValue:@"YES" forKey:@"autocheckin"];
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

    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [nav setNavigationBarHidden:YES];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) 
    {
        // Access the payload content
        checkinViewCtrl = [[CheckinViewController alloc] init];
        NSString *convString = [NSString stringWithFormat:@"We hope you enjoyed your visit to %@ on %@",[notification.userInfo objectForKey:@"busname"],[notification.userInfo objectForKey:@"dealDate"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:convString 
                                                        message:@"Were you able to attend?" 
                                                       delegate:self cancelButtonTitle:@"Yes" 
                                              otherButtonTitles:@"No",nil];

        [searchingradies setValue:[notification.userInfo objectForKey:@"dic"] forKey:@"dictionary"];
        [searchingradies setValue:[notification.userInfo objectForKey:@"userName"] forKey:@"userName"];
        [searchingradies synchronize]; 
        [alert show];
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }

    
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *temdic = [searchingradies objectForKey:@"dictionary"];
    NSString *username = [searchingradies objectForKey:@"userName"];
    NSLog(@"notificationTemdic:%@",temdic);
    if (buttonIndex == 0) {
        [checkinViewCtrl autocheckin:@"A" autocheckDetail:temdic userName:username];
        isAttended = YES;
    }
    else if (buttonIndex == 1){
        [checkinViewCtrl autocheckin:@"NA" autocheckDetail:temdic userName:username];
        isNotAttended=YES;
    }
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
        checkinstatusmessage=[[NSMutableString alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentelement isEqualToString:@"Date"]) {
        [checkinstatusmessage appendString:terstring];
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
}

@end
