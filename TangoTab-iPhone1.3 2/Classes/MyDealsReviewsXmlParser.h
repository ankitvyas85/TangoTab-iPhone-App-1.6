//
//  MyDealsReviewsXmlParser.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXMLParser.h"

@interface MyDealsReviewsXmlParser : BaseXMLParser {
	
	NSMutableDictionary *currentMyDealsDict;
	
	NSMutableArray *reviewsArray;
}

@property(nonatomic,retain)NSMutableDictionary *currentMyDealsDict;

@property(nonatomic,assign)NSMutableArray *reviewsArray;



-(void) handleElementEnd_errorMessage: (NSDictionary*) attributes withText:(NSString*) text;
-(void) handleElement_review: (NSDictionary*) attributes;
-(void) handleElementEnd_review;
-(void) handleElementEnd_user_rating: (NSDictionary*) attributes withText:(NSString*) text;
-(void)handleElementEnd_reviews;


@end

	