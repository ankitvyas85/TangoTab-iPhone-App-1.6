//
//  TermsOfUseViewController.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@interface TermsOfUseViewController : TrackedUIViewController {

	IBOutlet UIWebView *webView;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@end
