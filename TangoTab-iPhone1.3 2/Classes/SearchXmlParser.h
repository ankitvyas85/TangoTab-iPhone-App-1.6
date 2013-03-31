//
//  SearchXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 23/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"

@interface SearchXmlParser : BaseXMLParser {

	NSMutableDictionary *currentSearchDict;
	
	NSMutableArray *searchArray;
}

@property(nonatomic,retain)NSMutableDictionary *currentSearchDict;

@property(nonatomic,assign)NSMutableArray *searchArray;

@end
