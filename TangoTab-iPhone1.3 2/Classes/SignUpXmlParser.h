//
//  SignUpXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 03/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SignUpXmlParser : NSObject<NSXMLParserDelegate> {

	NSXMLParser *xmlParser;
	BOOL recordResults;
	NSMutableString *currentElementValue;
	NSMutableDictionary *responseDic;
	
}
@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) NSMutableString *currentElementValue;
@property (nonatomic, assign) BOOL recordResults;
@property (nonatomic, retain) NSMutableDictionary *responseDic;

@end
