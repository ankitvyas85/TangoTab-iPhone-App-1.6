//
//  PlacesXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 15/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesXmlParser.h"
#import "TangoTabAppDelegate.h"

@implementation PlacesXmlParser
@synthesize currentMyDealsDict;
@synthesize placesArray;
@synthesize searchingRadius;
//@synthesize arrDummyData;
//@synthesize iDummyData;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    
    //arrDummyData = [NSArray arrayWithObjects:@"100",@"30",@"200",@"35",@"19",@"23",@"38",@"94",@"54",nil];
    //iDummyData = 0;
    
    if (self != nil) 
    {
		elementStack = aElementStack;
		
		currentMyDealsDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		placesArray = [[NSMutableArray alloc] init];
		
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 
		return self;
}


-(void) handleElement_deal: (NSDictionary*) attributes
{
	[currentMyDealsDict release];
	currentMyDealsDict = [[NSMutableDictionary alloc] init];

	[currentMyDealsDict setObject:[attributes valueForKey:@"id"] forKey:@"id"];
}

-(void) handleElementEnd_deal
{

	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDealsWithLocationInPlaces = YES;
    
    double dist = 0.0;
    
	if (appDelegate.isDealsWithLocationInPlaces) {
		NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", [[currentMyDealsDict valueForKey:@"address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		NSURL *url = [NSURL URLWithString:urlString];
		
		NSString *locationString = [NSString stringWithContentsOfURL:url encoding:NSStringEncodingConversionAllowLossy error:nil];
        //[NSString stringWithContentsOfURL:url];

		NSArray *listItems = [locationString componentsSeparatedByString:@","];
		
		double latitude = 0.0;
		double longitude = 0.0;
		
		if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
			latitude = [[listItems objectAtIndex:2] doubleValue];
			longitude = [[listItems objectAtIndex:3] doubleValue];
		}
		else {
			//Show error
		}
		CLLocation *restLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];

        int distance = [appDelegate.currentLocation distanceFromLocation:restLocation];
        
        dist = (double)distance/Mile2KM/1000.00;

		[currentMyDealsDict setObject:[NSString stringWithFormat:@"%.0f",dist] forKey:@"distance_currentLocation"];
	}
	
    if ([self.searchingRadius isEqualToNumber:[NSNumber numberWithInt:0]] || (self.searchingRadius==nil)){
        self.searchingRadius = [NSNumber numberWithFloat:10.0];
    }
    
    if (dist < [self.searchingRadius doubleValue]) {
        if ([[currentMyDealsDict valueForKey:@"driving_distance"] doubleValue]<0) {
            [currentMyDealsDict setValue:[currentMyDealsDict valueForKey:@"distance_currentLocation"] forKey:@"driving_distance"];
        }
        [placesArray addObject:currentMyDealsDict];
    }
}


-(void) handleElementEnd_last_seen_timestamp: (NSDictionary*) attributes withText:(NSString*) text
{
	//NSString *documentPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSMutableDictionary *settingsDictionary;
	//NSString *mydictpath = [documentPath stringByAppendingPathComponent:@"settings.plist"];	
	//settingsDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:mydictpath];
	//[settingsDictionary setValue:text forKey:@"lastSeenDate"]; 
	//[settingsDictionary writeToFile:mydictpath atomically:YES];
    
    TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    [appDelegate.settingsDict setValue:text forKey:@"lastSeenDate"];
	[appDelegate saveObject:appDelegate.settingsDict];


	
}

-(void) handleElementEnd_business_name: (NSDictionary*) attributes withText:(NSString*) text
{

	[currentMyDealsDict setObject:text forKey: @"business_name"]; 

}
-(void) handleElementEnd_no_deals_available: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"no_deals_available"]; 
}
-(void) handleElementEnd_rest_deal_restrictions: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"rest_deal_restrictions"]; 
}

-(void) handleElementEnd_deal_name: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"deal_name"]; 
}
-(void) handleElementEnd_cuisine_type: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"cuisine_type"]; 
}
-(void) handleElementEnd_rest_deal_start_date: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"rest_deal_start_date"]; 
}

-(void) handleElementEnd_rest_deal_end_date: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"rest_deal_end_date"]; 
}
-(void) handleElementEnd_available_start_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"available_start_time"]; 
}
-(void) handleElementEnd_available_end_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"available_end_time"]; 
}
-(void) handleElementEnd_available_week_days: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"available_week_days"]; 
}
-(void) handleElementEnd_deal_description: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"deal_description"]; 
}
-(void) handleElementEnd_deal_credit_value: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"deal_credit_value"]; 
}
-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"address"]; 
}
-(void) handleElementEnd_location_rest_address: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"location_rest_address"]; 
        
    //NSArray *arrDummyData;
    //NSUInteger iDummyData;
   // [currentMyDealsDict setObject:[arrDummyData objectAtIndex:iDummyData++] forKey:@"driving_distance"];
    //[currentMyDealsDict setObject:[NSNumber numberWithDouble:100.00] forKey:@"driving_distance"];
    
  //  if (iDummyData>=[arrDummyData count])
  //      iDummyData = 0;
}

-(void) handleElementEnd_driving_distance: (NSDictionary*) attributes withText:(NSString*) text
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
	[currentMyDealsDict setObject:[f numberFromString:text] forKey: @"driving_distance"]; 
    [f release];
}

-(void) handleElementEnd_image_url: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"image_url"]; 
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"data_Parser_Error" object:self userInfo:nil];

}

-(void)handleElementEnd_deal_details
{
	
	if ([placesArray count] > 0) {
		if([[placesArray objectAtIndex:0] count] == 0)
		{
			placesArray = [[NSMutableArray alloc] init];
		}
	}
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isDealsWithLocationInPlaces) {
		appDelegate.isDealsWithLocationInPlaces = NO;
	}
	
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:placesArray forKey:@"array"];
	
	[notificationEngine postNotificationName:@"places_loaded" object:self userInfo:dictWrapper];
	
	return;
}

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.isDealsWithLocationInPlaces) {
		appDelegate.isDealsWithLocationInPlaces = NO;
	}
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"places_error_occured" object:self userInfo:d];
	return;
}
//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[placesArray release], placesArray = nil;
	[currentMyDealsDict release], currentMyDealsDict = nil;
    [searchingRadius release], searchingRadius = nil;
    
	[super dealloc];
}

@end
