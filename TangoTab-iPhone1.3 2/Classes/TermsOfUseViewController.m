//
//  TermsOfUseViewController.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TermsOfUseViewController.h"


@implementation TermsOfUseViewController
@synthesize webView;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Terms Of Use";
	
	NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"terms.html" ofType:nil];
	NSURL *url = [NSURL fileURLWithPath:urlStr];
	
	//NSURL *url = [NSURL URLWithString:urlStr];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[webView release];
    [super dealloc];
}


@end
