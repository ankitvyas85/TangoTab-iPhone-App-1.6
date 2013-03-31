//
//  FacebookSignup.h
//  TangoTab
//
//  Created by Mark Crutcher on 10/15/12.
//
//

#import <Foundation/Foundation.h>

@class ViewController;

@interface FacebookSignup : NSObject <NSXMLParserDelegate,UIAlertViewDelegate>

@property(nonatomic,retain)NSMutableData *webData;
@property(nonatomic,retain)NSXMLParser *parser;
@property(nonatomic,retain)NSMutableString *signupResult, *currentString;

@property (nonatomic, retain) ViewController *viewController;

- (void) signupWithToken: (NSString *) token email: (NSString *) email firstName: (NSString *) firstName LastName: (NSString *) lastName zipCode: (NSString *) zipCode;


@end
