//
//  UpdateZipCode.m
//  TangoTab
//
//  Created by Mark Crutcher on 11/1/12.
//
//

#import "UpdateZipCode.h"
#import "AppDelegate.h"

@implementation UpdateZipCode

@synthesize currentElement, userArray, result;

- (BOOL) invokeWithEmailAddress: (NSString *) email zipCode:(NSString *)zipCode {
    self.result = NO;
   
    
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    @try {
        NSString *serviceURL = [NSString stringWithFormat:@"%@/updateZipCode?emailId=%@&zipCode=%@",sharedDelegate.activeServerUrl,email,zipCode];
        NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        [self parseXML:terString];
    }
    @catch (NSException *exception) {
        
    }
    
    return self.result;
    
}

-(void) parseXML:(NSString *) xmlString
{
    userArray = [[NSMutableArray alloc] init];
    @try {
        
        NSURL *url = [NSURL URLWithString:[xmlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        debug_NSLog(@"WS-> %@",[url absoluteString]);
        NSData *xmlData = [NSData dataWithContentsOfURL:url];
        NSString *myString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        debug_NSLog(@"WSR <- %@", myString);
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        
        [parser setDelegate:self];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement=[[NSMutableString alloc]init];
    currentElement=[elementName copy];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    
    
}

@end
