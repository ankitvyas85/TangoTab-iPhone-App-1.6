//
//  MyDealsXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"


@interface MyDealsXmlParser : BaseXMLParser {
	
	
	NSMutableDictionary *currentplacesDict;
	
	NSMutableArray *placesArray;
}

@property(nonatomic,retain)NSMutableDictionary *currentplacesDict;

@property(nonatomic,assign)NSMutableArray *placesArray;



-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text;

-(void) handleElement_detail: (NSDictionary*) attributes;
-(void) handleElementEnd_detail;
-(void) handleElementEnd_con_res_id: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_business_name: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_reserved_time_stamp: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_address: (NSDictionary*) attributes withText:(NSString*) text;
-(void)handleElementEnd_mydeal_details;

@end
