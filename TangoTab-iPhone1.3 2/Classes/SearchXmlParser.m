//
//  SearchXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 23/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchXmlParser.h"


@implementation SearchXmlParser
@synthesize currentSearchDict;
@synthesize searchArray;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) 
    {
		elementStack = aElementStack;
		
		currentSearchDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		searchArray = [[NSMutableArray alloc] init];
		
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 
		return self;
}


-(void) handleElement_deal: (NSDictionary*) attributes
{
	[currentSearchDict release];
	
	currentSearchDict = [[NSMutableDictionary alloc] init];
	[currentSearchDict setObject:[attributes valueForKey:@"id"] forKey:@"id"];
}

-(void) handleElementEnd_deal
{
	[searchArray addObject:currentSearchDict];
	
}

-(void) handleElementEnd_business_name: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"business_name"]; 
}

-(void) handleElementEnd_cuisine_type: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"cuisine_type"]; 
}

-(void) handleElementEnd_deal_name: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"deal_name"]; 
}

-(void) handleElementEnd_rest_deal_restrictions: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"rest_deal_restrictions"]; 
}
-(void) handleElementEnd_rest_deal_start_date: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"rest_deal_start_date"]; 
}
-(void) handleElementEnd_rest_deal_end_date: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"rest_deal_end_date"]; 
}
-(void) handleElementEnd_available_start_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"available_start_time"]; 
}
-(void) handleElementEnd_available_end_time: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"available_end_time"]; 
}

-(void) handleElementEnd_available_week_days: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"available_week_days"]; 
}

-(void) handleElementEnd_deal_description: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"deal_description"]; 
}

-(void) handleElementEnd_deal_credit_value: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"deal_credit_value"]; 
}
-(void) handleElementEnd_location_rest_address: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"location_rest_address"]; 
}


-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"address"]; 
}

-(void) handleElementEnd_no_deals_available: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"no_deals_available"]; 
}
-(void) handleElementEnd_image_url: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentSearchDict setObject:text forKey: @"image_url"]; 
}


-(void)handleElementEnd_deal_details
{
	
	if ([searchArray count] > 0) {
		if([[searchArray objectAtIndex:0] count] == 0)
		{
			searchArray = [[NSMutableArray alloc] init];
		}
	}
	
	
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:searchArray forKey:@"array"];
	
	[notificationEngine postNotificationName:@"search_deals_loaded" object:self userInfo:dictWrapper];
	
	return;
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"search_data_Parser_Error" object:self userInfo:nil];
	
}

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text
{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"search_error_occured" object:self userInfo:d];
	return;
}
//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[searchArray release], searchArray = nil;
	
	[super dealloc];
}

@end
