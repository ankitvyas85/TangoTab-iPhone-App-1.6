//
//  IsActiveAccount.h
//  TangoTab
//
//  Created by Mark Crutcher on 10/26/12.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ActiveAccountType) {
    NotValid,
    Valid,
    Linked
};

@interface IsActiveAccount : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableArray *userArray;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *linkedAccount;
@property ActiveAccountType result;

- (ActiveAccountType) invokeWithEmailAddress: (NSString *) email facebookId: (NSString *) facebookId;

@end
