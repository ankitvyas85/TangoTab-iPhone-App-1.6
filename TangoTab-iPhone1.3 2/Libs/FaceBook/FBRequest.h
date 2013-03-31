

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FBRequestDelegate;

/**
 * Do not use this interface directly, instead, use method in Facebook.h
 */
@interface FBRequest : NSObject {
  id<FBRequestDelegate> _delegate;
  NSString*             _url;
  NSString*             _httpMethod;
  NSMutableDictionary*  _params;
  NSURLConnection*      _connection;
  NSMutableData*        _responseText;
}


@property(nonatomic,assign) id<FBRequestDelegate> delegate;

/**
 * The URL which will be contacted to execute the request.
 */
@property(nonatomic,copy) NSString* url;

/**
 * The API method which will be called.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The dictionary of parameters to pass to the method.
 *
 * These values in the dictionary will be converted to strings using the 
 * standard Objective-C object-to-string conversion facilities.
 */
@property(nonatomic,assign) NSMutableDictionary* params;


@property(nonatomic,assign) NSURLConnection*  connection;

@property(nonatomic,assign) NSMutableData* responseText;


                        
+ (FBRequest*)getRequestWithParams:(NSMutableDictionary *) params
                        httpMethod:(NSString *) httpMethod
                          delegate:(id<FBRequestDelegate>)delegate
                        requestURL:(NSString *) url;
- (BOOL) loading;

- (void) connect;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate 
 */
@protocol FBRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest*)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error;

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest*)request didLoadRawResponse:(NSData*)data;

@end

