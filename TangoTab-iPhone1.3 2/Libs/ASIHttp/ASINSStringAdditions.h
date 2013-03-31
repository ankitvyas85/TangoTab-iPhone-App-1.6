

#import <Foundation/Foundation.h>

@interface NSString (CookieValueEncodingAdditions)

- (NSString *)encodedCookieValue;
- (NSString *)decodedCookieValue;

@end
