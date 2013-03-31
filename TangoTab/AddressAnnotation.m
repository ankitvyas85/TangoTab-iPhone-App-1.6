//
//  AddressAnnotation.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"

#define REUSABLE_PIN_RED	@"Red" 
#define REUSABLE_PIN_GREEN  @"Green" 
#define REUSABLE_PIN_PURPLE @"Purple"

@implementation AddressAnnotation

@synthesize coordinate     = _coordinate;
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize pinID;
@synthesize pinColor;

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
+ (NSString *)	reusableIdentifierforPinColor :(MKPinAnnotationColor)paramColor{
    NSString *result = nil;
    switch (paramColor){ 
        case MKPinAnnotationColorRed:{
            result = REUSABLE_PIN_RED; 
            break;
        } case MKPinAnnotationColorGreen:{
            result = REUSABLE_PIN_GREEN; 
            break;
        } case MKPinAnnotationColorPurple:{
            result = REUSABLE_PIN_PURPLE; 
            break;
        } 
    }
    return result;
}

-(void) dealloc
{	
	[_title release];
	[super dealloc];
}


@end
