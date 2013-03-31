//
//  PrivacyPolicyViewController.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EasyTracker.h"
#import "GANTracker.h"

@interface PrivacyPolicyViewController : TrackedUIViewController

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UINavigationItem *backBarButton;
@end
