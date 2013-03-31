

#import "FBLoginDialog.h"
#import "FBRequest.h"

@protocol FBSessionDelegate;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface Facebook : NSObject<FBLoginDialogDelegate>{
  NSString* _accessToken;
  NSDate* _expirationDate;
  id<FBSessionDelegate> _sessionDelegate;
  FBRequest* _request;
  FBDialog* _loginDialog;
  FBDialog* _fbDialog;
  
}

@property(nonatomic, copy) NSString* accessToken;

@property(nonatomic, copy) NSDate* expirationDate;

@property(nonatomic, assign) id<FBSessionDelegate> sessionDelegate;


- (void) authorize:(NSString*) application_id
       permissions:(NSArray*) permissions
          delegate:(id<FBSessionDelegate>) delegate;

- (void) logout:(id<FBSessionDelegate>) delegate;

- (void) requestWithParams:(NSMutableDictionary *) params 
               andDelegate:(id <FBRequestDelegate>) delegate;

- (void) requestWithMethodName:(NSString *) methodName 
                     andParams:(NSMutableDictionary *) params 
                 andHttpMethod:(NSString *) httpMethod 
                   andDelegate:(id <FBRequestDelegate>) delegate;

- (void) requestWithGraphPath:(NSString *) graphPath 
                  andDelegate:(id <FBRequestDelegate>) delegate;

- (void) requestWithGraphPath:(NSString *)graphPath 
                    andParams:(NSMutableDictionary *) params  
                  andDelegate:(id <FBRequestDelegate>) delegate;

- (void) requestWithGraphPath:(NSString *)graphPath 
                    andParams:(NSMutableDictionary *) params 
                andHttpMethod:(NSString *) httpMethod 
                  andDelegate:(id <FBRequestDelegate>) delegate;

- (void) dialog:(NSString *) action 
    andDelegate:(id<FBDialogDelegate>) delegate;

- (void) dialog:(NSString *) action 
      andParams:(NSMutableDictionary *) params 
    andDelegate:(id <FBDialogDelegate>) delegate;

- (BOOL) isSessionValid;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate 
 */
@protocol FBSessionDelegate <NSObject>

@optional

/**
 * Called when the dialog successful log in the user
 */
- (void)fbDidLogin;

/**
 * Called when the user dismiss the dialog without login
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user is logged out
 */
- (void)fbDidLogout;

@end
