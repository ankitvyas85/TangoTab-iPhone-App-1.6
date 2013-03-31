//
//  UserValidationParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 18/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"

@interface UserValidationParser : BaseXMLParser {
	NSMutableDictionary *userDetailsDict;
	
}
@property(nonatomic,retain) NSMutableDictionary *userDetailsDict;
@end
