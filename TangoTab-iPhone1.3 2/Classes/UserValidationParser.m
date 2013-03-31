//
//  UserValidationParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserValidationParser.h"


@implementation UserValidationParser
@synthesize userDetailsDict;


- (id) initWithElementStack:(NSMutableArray *)aElementStack{
    self = [super initWithElementStack:aElementStack];
    if (self != nil) {
		elementStack = aElementStack;
		
		userDetailsDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		return self;
    }	
	else 
		return self;
	
}


-(void) handleElement_user_details: (NSDictionary*) attributes{
	[userDetailsDict release];
	userDetailsDict = [[NSMutableDictionary alloc] init];
	
}

-(void) handleElementEnd_deal{
	
}

-(void) handleElementEnd_first_name: (NSDictionary*) attributes withText:(NSString*) text{
	[userDetailsDict setObject:text forKey: @"first_name"]; 
}
-(void) handleElementEnd_last_name: (NSDictionary*) attributes withText:(NSString*) text{
	[userDetailsDict setObject:text forKey: @"last_name"]; 
}
-(void) handleElementEnd_zip_code: (NSDictionary*) attributes withText:(NSString*) text{
	[userDetailsDict setObject:text forKey: @"zip_code"]; 
}

-(void) handleElementEnd_mobile_phone: (NSDictionary*) attributes withText:(NSString*) text{
	[userDetailsDict setObject:text forKey: @"mobile_phone"]; 
}
-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text{
	[userDetailsDict setObject:text forKey: @"address"]; 
}
-(void) handleElementEnd_message: (NSDictionary*) attributes withText:(NSString*) text{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"message"];
	[notificationEngine postNotificationName:@"in_valid_user" object:self userInfo:d];
	return;
}

-(void)handleElementEnd_user_details{
	[notificationEngine postNotificationName:@"valid_user" object:self userInfo:userDetailsDict];	
	return;
}

-(void) failToParseData{
	[notificationEngine postNotificationName:@"userValidation_data_Parser_Error" object:self userInfo:nil];
	
}


-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text{
	NSDictionary *d = [NSDictionary dictionaryWithObject:[NSString stringWithString:text] forKey:@"errorMessage"];
	
	[notificationEngine postNotificationName:@"user_validation_error_occured" object:self userInfo:d];
	return;
}
//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc{
	[userDetailsDict release], userDetailsDict = nil;
	[super dealloc];
}
@end
