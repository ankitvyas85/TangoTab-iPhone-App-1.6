//
//  AddressAnnotation.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

@synthesize coordinate     = _coordinate;
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize pinID;

- (NSString *)title{
	NSString *string = [NSString stringWithFormat:@"%d)%@",pinID+1,_title];

	return string;
}

- (NSString *)subtitle {
	
	
	return [NSString stringWithFormat:@"%@",_subTitle];
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title andID:(NSUInteger)pin subTitle:(NSString *)subTitle {
	
	_coordinate = coordinate;
	_title = [title retain];
	_subTitle = [subTitle retain];
	pinID = pin;
	return self;
}

-(void) dealloc
{	
	[_title release];
	[super dealloc];
}


@end
