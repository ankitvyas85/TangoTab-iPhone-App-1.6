//
//  LoginView.m
//  TangoTab
//
//  Created by Mark Crutcher on 10/19/12.
//
//

#import "LoginView.h"

@implementation LoginView
@synthesize facebookBtn, signInBtn, signUpBtn, serverLabel;

- (id)initWithFrame:(CGRect)frame
{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LoginView"
                                                          owner:nil
                                                        options:nil];
    
    
    if ([arrayOfViews count] < 1){
        [self release];
        return nil;
    }
    
    LoginView *newView = [[arrayOfViews objectAtIndex:0] retain];
    [newView setFrame:frame];
    
    [self release];
    self = newView;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
