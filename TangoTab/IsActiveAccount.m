//
//  IsActiveAccount.m
//  TangoTab
//
//  Created by Mark Crutcher on 10/26/12.
//
//

#import "IsActiveAccount.h"
#import "AppDelegate.h"

@implementation IsActiveAccount
@synthesize currentElement, userArray, result, userId, linkedAccount;

- (ActiveAccountType) invokeWithEmailAddress: (NSString *) email facebookId:(NSString *)facebookId {
    self.result = NotValid;
    self.userId = nil;
    
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    @try {
        NSString *serviceURL = [NSString stringWithFormat:@"%@/isactiveaccount?emailId=%@&facebookId=%@",sharedDelegate.activeServerUrl,email,facebookId];
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
    
    if ([currentElement isEqualToString:@"user_id"]) {
      if (![terstring isEqualToString:@""])
      {
          self.result = Valid;
          self.userId = terstring;
      }
    }

    if ([currentElement isEqualToString:@"email"]) {
        if (![terstring isEqualToString:@""])
        {
            self.linkedAccount = terstring;
        }
    }

    if ([currentElement isEqualToString:@"facebook_id"]) {
        if (![terstring isEqualToString:@""])
        {
            self.result = Linked;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    

    
}

@end
