//
//  RedeemXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 23/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RedeemXmlParser.h"


@implementation RedeemXmlParser
- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) 
    {
		elementStack = aElementStack;
		
        delegate = self;
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }
	else 
		return self;
	
	
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"redeem_data_Parser_Error" object:self userInfo:nil];
	
}

-(void)handleElementEnd_message:(NSDictionary*) attributes withText:(NSString*) text
{
	
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:text forKey:@"message"];
	
	[notificationEngine postNotificationName:@"deal_used_loaded" object:self userInfo:dictWrapper];
	
	return;
}

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text
{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"update_error_occured" object:self userInfo:d];
	return;
}
//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[super dealloc];
}

@end
