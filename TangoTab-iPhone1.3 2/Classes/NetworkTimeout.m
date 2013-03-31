//
//  NetworkTimeout.m
//  TangoTab
//
//  Created by Ria Chandra on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkTimeout.h"
#import "TangoTabAppDelegate.h"
#import "MyDealsViewController.h"
//#import "TangoTabSessionDelegate.h"
@implementation NetworkTimeout


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
}

/*** Close button action ***/
-(void)closeAction
{
	[self dismissModalViewControllerAnimated:YES];

}

/***  Use text button action***/


- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0 && alert.tag==101)
	{
		MyDealsViewController *delas = [[MyDealsViewController alloc] init];
		[delas stopActivityIndicatorView];
		[delas release];
	}
}



/** Open SMS application **/

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
    [super dealloc];
}


@end
