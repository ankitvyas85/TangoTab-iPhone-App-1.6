//
//  BaseXMLParser.h
//  TangoTab
//
//  Created by dannymcalerney on 8/18/09.
//  Copyright 2009 Struck Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

@class ASIHTTPRequest;
@class ASINetworkQueue;

@interface BaseXMLParser : NSObject <NSXMLParserDelegate>

{
	
	id delegate;
	
	NSNotificationCenter *notificationEngine;
	
	//this is what the parser uses to keep track of what 
	//string it's trying to parse
	NSMutableString* currentTextString;
	
	//These are the elements we want to get values from
	NSMutableArray* elementStack;
			
	//keeps track of what element we are on
	NSString* currentElement;
	//keeps track of that elements attributes
	NSDictionary* currentAttributes;
	
	ASINetworkQueue *networkQueue;
	
	//For Complex XML Sructures we can declare variables to keep track
	//of which node we are parsing so we have easy access to their respective
	//parents.  For instance, If we get a whole bunch of <Venue></Venue>elements
	//we could declare currentVenue so when we start parsing that venues child tags (eg. title, location)
	//in to a dictionary, we can use currentVenue to access that venue instance as a key.
	//NSString *currentVenue;
	//NSString *currentVenueSeating;
	//NSString *currentSection;
	
	//maybe declare a dictionary to hold all the data
	//this might be the one you want the parser to return
	//NSMutableDictionary *dataDict;
	bool isNetworkTimeout;
	
	//***************** Add by aftab on 2010-12-01 *****************
	//***************** When pressing the continue button after conn time out then re-conntect to server ****************
	BOOL isConnTimeOut;
	NSString *strConnURL;
	
}
@property(nonatomic,retain)id delegate;
@property(nonatomic,retain)NSNotificationCenter *notificationEngine;
@property(nonatomic,retain)NSMutableString *currentTextString;
@property(nonatomic,retain)NSMutableArray *elementStack;
@property(nonatomic,retain)NSString *currentElement;
@property(nonatomic,retain)NSDictionary *currentAttributes;
@property(nonatomic,retain)ASINetworkQueue *networkQueue;
//@property(nonatomic,retain)NSMutableDictionary *dataDict;
@property(nonatomic,assign)bool isNetworkTimeout;


- (id) initWithElementStack:(NSMutableArray *)aElementStack;

//Networking functions
- (void)requestDone:(ASIHTTPRequest *)request;
- (void)requestWentWrong:(ASIHTTPRequest *)request;

-(BOOL) loadFromURL:(NSString*) name;

-(NSString*) ancestorElementAtIndex:(int) index;


//Here's where we put all our custom tag handling functions
//Here are the formats
/*
-(void) handleElement_Element1: (NSDictionary*) attributes;
-(void) handleElementEnd_Element1: (NSDictionary*) attributes;
-(void) handleElementEnd_element1: (NSDictionary*) attributes withText:(NSString*) text;
*/

@end
