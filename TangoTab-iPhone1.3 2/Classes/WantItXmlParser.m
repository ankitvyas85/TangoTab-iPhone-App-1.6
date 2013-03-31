//
//  WantItXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 03/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WantItXmlParser.h"


@implementation WantItXmlParser

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
	[notificationEngine postNotificationName:@"wantIt_data_Parser_Error" object:self userInfo:nil];
	
}

-(void)handleElementEnd_message:(NSDictionary*) attributes withText:(NSString*) text
{
	
	NSMutableDictionary *dictWrapper = [NSMutableDictionary dictionaryWithObject:text forKey:@"message"];
	
	[notificationEngine postNotificationName:@"have_deal_loaded" object:self userInfo:dictWrapper];
	
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
