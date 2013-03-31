//
//  MyDealsReviewsXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDealsReviewsXmlParser.h"


@implementation MyDealsReviewsXmlParser
@synthesize currentMyDealsDict;
@synthesize reviewsArray;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) 
    {
		elementStack = aElementStack;
		
		currentMyDealsDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		reviewsArray = [[NSMutableArray alloc] init];
		
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 
		return self;
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"myDealsReviews_data_Parser_Error" object:self userInfo:nil];
	
}

-(void) handleElement_review: (NSDictionary*) attributes
{
	[currentMyDealsDict release];
	
	currentMyDealsDict = [[NSMutableDictionary alloc] init];
}

-(void) handleElementEnd_review
{
	[reviewsArray addObject:currentMyDealsDict];
	
}

-(void) handleElementEnd_user_rating: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"user_rating"]; 
}

-(void) handleElementEnd_user_comment: (NSDictionary*) attributes withText:(NSString*) text
{
	[currentMyDealsDict setObject:text forKey: @"user_comment"]; 
}


-(void)handleElementEnd_reviews
{
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:reviewsArray forKey:@"array"];
	
	[notificationEngine postNotificationName:@"reviews_loaded" object:self userInfo:dictWrapper];
	
	return;
}

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text
{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"reviews_error_occured" object:self userInfo:d];
	return;
}
//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[reviewsArray release], reviewsArray = nil;
//	[currentMyDealsDict release];
	[super dealloc];
}
@end
