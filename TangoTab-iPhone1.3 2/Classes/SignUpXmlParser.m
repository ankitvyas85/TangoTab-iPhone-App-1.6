//
//  SignUpXmlParser.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 03/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignUpXmlParser.h"


@implementation SignUpXmlParser
@synthesize currentElementValue, xmlParser, recordResults,responseDic;

- (id) initWithData:(NSData *)data {
    self = [super init];
    if (self != nil) {
		xmlParser = [[NSXMLParser alloc] initWithData:data];
		[xmlParser setDelegate:self];
		[xmlParser setShouldResolveExternalEntities:YES];
    }
    return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"message"]) {
		responseDic = [[NSMutableDictionary alloc] init];
	}
	
	recordResults = YES;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
	string = [string stringByTrimmingCharactersInSet:
			  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(recordResults)
	{
		if (!currentElementValue) {
			currentElementValue = [[NSMutableString alloc] initWithString:string];
		}
		else {
			[currentElementValue appendString:string];
		}
		
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"message"]) {
		[responseDic setValue:currentElementValue forKey:elementName];
	}
	
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterParsing_signUp_account" object:self userInfo:responseDic];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fail_to_parse_data" object:self userInfo:nil];

}

-(void)dealloc{
	[responseDic release];
	[xmlParser release];
	[currentElementValue release];
	[super dealloc];
	
}

@end
