//
//  CheckInXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 23/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"

@interface CheckInXmlParser : BaseXMLParser {
	NSMutableDictionary *currentMyDealsDict;
	
	NSMutableArray *reviewsParserArray;
}
@property(nonatomic,retain)NSMutableDictionary *currentMyDealsDict;

@property(nonatomic,assign)NSMutableArray *reviewsParserArray;
-(void)handleElementEnd_message:(NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text;
@end
