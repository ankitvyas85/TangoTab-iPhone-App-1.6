//
//  ReviewsXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReviewsXmlParser.h"


@implementation ReviewsXmlParser
@synthesize currentMyDealsDict;
@synthesize reviewsParserArray;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) 
    {
		elementStack = aElementStack;
		
		currentMyDealsDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		reviewsParserArray = [[NSMutableArray alloc] init];
		
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 

		return self;
}


-(void) handleElement_review: (NSDictionary*) attributes
{
	if (currentMyDealsDict) {
		[currentMyDealsDict release];
	}
	
	currentMyDealsDict = [[NSMutableDictionary alloc] init];
}

-(void) handleElementEnd_review
{
	[reviewsParserArray addObject:currentMyDealsDict];
	
}


-(void) failToParseData{
	[notificationEngine postNotificationName:@"reviews_data_Parser_Error" object:self userInfo:nil];
	
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
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:reviewsParserArray forKey:@"array"];
	
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
	[currentMyDealsDict release];
//	[reviewsParserArray release];// reviewsParserArray = nil;
	
	[super dealloc];
}

@end
