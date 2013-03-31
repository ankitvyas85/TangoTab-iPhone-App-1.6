//
//  ZipcodeView.m
//  TangoTab
//
//  Created by Mark Crutcher on 10/26/12.
//
//

#import "ZipcodeView.h"

@implementation ZipcodeView

@synthesize createBtn, homeZipCode, workZipCode;

- (id)initWithFrame:(CGRect)frame
{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ZipcodeView"
                                                          owner:nil
                                                        options:nil];
    
    
    if ([arrayOfViews count] < 1){
        [self release];
        return nil;
    }
    
    ZipcodeView *newView = [[arrayOfViews objectAtIndex:0] retain];
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
