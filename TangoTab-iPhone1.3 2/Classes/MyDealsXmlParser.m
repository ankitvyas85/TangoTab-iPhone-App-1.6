//
//  MyDealsXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDealsXmlParser.h"
#import "TangoTabAppDelegate.h"

@implementation MyDealsXmlParser
@synthesize currentplacesDict;
@synthesize placesArray;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) 
    {
		elementStack = aElementStack;
		
		currentplacesDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		placesArray = [[NSMutableArray alloc] init];
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 
		return self;
}


-(void) handleElement_detail: (NSDictionary*) attributes
{
	[currentplacesDict release];
	
	currentplacesDict = [[NSMutableDictionary alloc] init];
}

-(void) handleElementEnd_detail
{
	TangoTabAppDelegate *appDelegate = (TangoTabAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", [[currentplacesDict valueForKey:@"address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSString *locationString = [NSString stringWithContentsOfURL:url];
	
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
	//		CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:17.402632 longitude:78.383574];
	//		CLLocation *hydLocation = [[CLLocation alloc] initWithLatitude:17.385759 longitude:78.466916];
	
	int distance = [appDelegate.currentLocation getDistanceFrom:restLocation];
	[currentplacesDict setObject:[NSString stringWithFormat:@"%i",distance] forKey:@"distance_currentLocation"];
	
	[placesArray addObject:currentplacesDict];
	
}

-(void) handleElementEnd_con_res_id: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"con_res_id"]; 
}

-(void) handleElementEnd_deal_id: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"deal_id"]; 
}
-(void) handleElementEnd_deal_name: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"deal_name"]; 
}

-(void) handleElementEnd_cuisine_type: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"cuisine_type"]; 
}
-(void) handleElementEnd_deal_description: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"deal_description"]; 
}

-(void) handleElementEnd_deal_restrictions: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"deal_restrictions"]; 
}
-(void) handleElementEnd_start_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"start_time"]; 
}
-(void) handleElementEnd_end_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"end_time"]; 
}
-(void) handleElementEnd_image_url: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"image_url"]; 
}

-(void) handleElementEnd_business_name: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"business_name"]; 
}

-(void) handleElementEnd_reserved_time_stamp: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"reserved_time_stamp"]; 
}
-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentplacesDict setObject:text forKey: @"address"]; 
}

-(void) handleElementEnd_message: (NSDictionary*) attributes withText:(NSString*) text
{
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:text forKey:@"message"];
	[notificationEngine postNotificationName:@"invalid_user" object:self userInfo:dictWrapper];
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"myDeals_data_Parser_Error" object:self userInfo:nil];
	
}

-(void)handleElementEnd_mydeal_details
{
	
	if ([placesArray count] > 0) {
		if([[placesArray objectAtIndex:0] count] == 0)
		{
			placesArray = [[NSMutableArray alloc] init];
		}
	}
	
	
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:placesArray forKey:@"array"];
	
	[notificationEngine postNotificationName:@"myDeals_loaded" object:self userInfo:dictWrapper];
	
	return;
}

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text
{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"myDeals_error_occured" object:self userInfo:d];
	return;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[placesArray release], placesArray = nil;
	[currentplacesDict release];
	[super dealloc];
}
@end
