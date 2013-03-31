//
//  ZipcodeUpdateView.m
//  TangoTab
//
//  Created by Mark Crutcher on 11/1/12.
//
//

#import "ZipcodeUpdateView.h"

@implementation ZipcodeUpdateView

@synthesize homeZipCode, workZipCode, updateBtn;

- (id)initWithFrame:(CGRect)frame
{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ZipcodeUpdateView"
                                                          owner:nil
                                                        options:nil];
    
    
    if ([arrayOfViews count] < 1){
        [self release];
        return nil;
    }
    
    ZipcodeUpdateView *newView = [[arrayOfViews objectAtIndex:0] retain];
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
