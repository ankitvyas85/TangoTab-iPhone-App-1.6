//
//  PlacesXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 15/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"


@interface PlacesXmlParser :BaseXMLParser {
	
	NSMutableDictionary *currentMyDealsDict;
	
	NSMutableArray *placesArray;
    
    NSNumber *searchingRadius;
}

@property(nonatomic,retain)NSMutableDictionary *currentMyDealsDict;

@property(nonatomic,assign)NSMutableArray *placesArray;

@property(nonatomic,retain)NSNumber *searchingRadius;

//@property(nonatomic,retain) NSArray *arrDummyData;
//@property(nonatomic,assign) NSUInteger iDummyData;

-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text;

-(void) handleElement_deal: (NSDictionary*) attributes;
-(void) handleElementEnd_deal;
-(void) handleElementEnd_business_name: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_cuisine_type: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_available_week_days: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_deal_details;

@end
