


#import "FBDialog.h"

@protocol FBLoginDialogDelegate;

/**
 * Do not use this interface directly, instead, use authorize in Facebook.h
 *
 * Facebook Login Dialog interface for start the facebook webView login dialog.
 * It start pop-ups prompting for credentials and permissions.
 */

@interface FBLoginDialog : FBDialog {
  id<FBLoginDialogDelegate> _loginDelegate;
}

-(id) initWithURL:(NSString *) loginURL 
      loginParams:(NSMutableDictionary *) params 
      delegate:(id <FBLoginDialogDelegate>) delegate;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol FBLoginDialogDelegate <NSObject> 

- (void) fbDialogLogin:(NSString *) token expirationDate:(NSDate *) expirationDate;

- (void) fbDialogNotLogin:(BOOL) cancelled;

@end


