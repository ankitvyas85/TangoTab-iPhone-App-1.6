//
//  UpdateZipCode.h
//  TangoTab
//
//  Created by Mark Crutcher on 11/1/12.
//
//

#import <Foundation/Foundation.h>

@interface UpdateZipCode : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableArray *userArray;
@property BOOL result;

- (BOOL) invokeWithEmailAddress: (NSString *) email zipCode: (NSString *) zipCode;

@end
