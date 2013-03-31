//
//  BaseXMLParser.m
//  TangoTab
//
//  Created by dannymcalerney on 8/18/09.
//  Copyright 2009 Struck Creative. All rights reserved.
//

#import "BaseXMLParser.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface BaseXMLParser()


-(void) pushElement:(NSString*) elementName;
-(void) popElement;
-(void) closeElementWithText;

@end

@implementation BaseXMLParser


@synthesize currentTextString;
@synthesize elementStack;
@synthesize currentElement;
@synthesize currentAttributes;
//@synthesize dataDict;

@synthesize notificationEngine;
@synthesize delegate;
@synthesize networkQueue;
@synthesize isNetworkTimeout;

- (id) initWithElementStack:(NSMutableArray *)aElementStack
{
    self = [super init];

    if (self != nil) 
    {
		isConnTimeOut = NO;
		notificationEngine = [NSNotificationCenter defaultCenter];
		
		elementStack=[[NSMutableArray alloc]init];
		elementStack = aElementStack;
//		dataDict = [[NSMutableDictionary alloc] init];
        delegate = self;
		if (networkQueue) {
			[networkQueue release];
		}
		networkQueue = [[ASINetworkQueue alloc] init];
		
		return self;
    }
	else 
		return self;
}

- (void) dealloc
{
	[elementStack release], elementStack = nil;

    [currentElement release], currentElement = nil;
    [currentAttributes release], currentAttributes = nil;
	[networkQueue release];
	

//	[dataDict release], dataDict = nil;
	[currentTextString release], currentTextString = nil;
	[strConnURL release],strConnURL = nil;
    [super dealloc];
}

- (BOOL) loadFromURL:(NSString*)name
{
	if (strConnURL) {
		[strConnURL release];
	}
	
    strConnURL = [[NSString alloc] initWithCString:(char *)name];
	NSString* url = [NSString stringWithFormat:@"%@", name ];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	url = [url stringByReplacingOccurrencesOfString:@"#" withString:@"%32"];
    
	isNetworkTimeout=NO;
	[networkQueue cancelAllOperations];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
	
	request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

	if(isConnTimeOut)
		[request setTimeOutSeconds:60];
	[request setQueue:networkQueue];
	[request setDelegate:self];
	[request setValidatesSecureCertificate:YES];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	//[request setupPostBody]
	[networkQueue setSuspended:NO];
	[networkQueue addOperation:request];
	
	[networkQueue go];
	[request release];
	
	return YES;
}


-(BOOL) parseXML:(NSString *) xmlString
{
	NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	parser.delegate = self;
	[parser parse];
	
    NSError *parseError = [parser parserError];
	[parser release];
	
    if (parseError) 
	{
        return NO;
    }
	else
	{
        return YES;
	}
	
}
//Executes after getting xml file
- (void)requestDone:(ASIHTTPRequest *)request
{
	NSString *response = [request responseString];
	[self parseXML:response];
}
#pragma mark Alert NetworkTimeout
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSString *description = [NSString stringWithString:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
	[notificationEngine postNotificationName:@"hide_activity_indicator" object:self userInfo:nil];
	UIAlertView *alert;
	if([description isEqualToString:@"Cannot connect to TangoTab service. This might be due to your data connection. If this problem persists, please notify TangoTab at help@tangotab.com."] || [description isEqualToString:@"It appears there is no data connection, please check your settings."])
	{
		alert = [[UIAlertView alloc] init];
		alert.tag=101;
		[alert setTitle:@"Network Error"];
		[alert setMessage:description];
		[alert setDelegate:self];
		//[alert addButtonWithTitle:@"Continue"];
		[alert addButtonWithTitle:@"OK"];
		//[alert setNumberOfRows:3];

	}
	else 
	{
		alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	}
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag==101 && buttonIndex == 0)
	{
		isNetworkTimeout=YES;
		//NSDictionary *n = [NSDictionary dictionaryWithObject:dataDict forKey:@"responseData"];
		//[d setValue:anotherValue forKey:@"anotherValue"];
		[notificationEngine postNotificationName:@"network_timeout" object:self userInfo:nil];
		//NetworkTimeout *viewController=[[NetworkTimeout alloc]init];
		//[self addSubview:viewController.view];
	}
	else if (alertView.tag==101 && buttonIndex == 0)
	{
		//isConnTimeOut = YES;
		//[self loadFromBundle:strConnURL];
	}
	
}

-(void) pushElement:(NSString*) elementName
{
	@try {
	
	if (elementStack.count>0)
        [elementStack addObject:elementName];
	}
	@catch (NSException * e) {

	}
	@finally {
		;
	}

}
-(void) popElement
{
    [elementStack removeObjectAtIndex:elementStack.count-1];    
}
-(NSString*) ancestorElementAtIndex:(int) index
{
    return [elementStack objectAtIndex: elementStack.count-(index+1)];
}

-(void) parser: (NSXMLParser *) parser didStartElement: (NSString*) elementName namespaceURI: (NSString*) namespaceURI qualifiedName: (NSString*) qName attributes: (NSDictionary*) attributeDict
{
    if( currentTextString )
    {
        [currentTextString release];
        currentTextString = nil;
    }
    self.currentElement = elementName;
    self.currentAttributes = attributeDict;
    [self pushElement: elementName];
	
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElement_%@:", elementName] );
    if( [delegate respondsToSelector:sel] )
    {
        [delegate performSelector:sel withObject: attributeDict];
    }
}

-(void) closeElementWithText
{
    NSString* text = [currentTextString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if( text && currentElement )
    {
        SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@:withText:", currentElement] );
        if( [delegate respondsToSelector:sel] )
        {
            [delegate performSelector:sel withObject: currentAttributes withObject: text];
            [currentTextString release];
            currentTextString = nil;
        }
    }
}

-(void)     parser: (NSXMLParser*) parser 
   foundCharacters: (NSString*) string 
{    
    if( string && [string length] > 0 )
    {
        if( !currentTextString )
        {
            currentTextString = [[NSMutableString alloc] init];
        }
        [currentTextString appendString:string];
    }
}

-(void) parser: (NSXMLParser*) parser 
 didEndElement: (NSString*) elementName 
  namespaceURI: (NSString *) namespaceURI 
 qualifiedName: (NSString *) qName
{
    [self closeElementWithText];
    self.currentElement = nil;
    [self popElement];
	
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@", elementName] );
    if( [delegate respondsToSelector:sel] )
    {
        [delegate performSelector:sel];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"failToParseData"] );
	[delegate performSelector:sel];
	
}



@end

