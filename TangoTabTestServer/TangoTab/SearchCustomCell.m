//
//  SearchCustomCell.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchCustomCell.h"

@implementation SearchCustomCell
@synthesize restaurantNameLabel;
@synthesize dealNameLabel;
@synthesize restaurantType;
@synthesize timeStampLabel;
@synthesize dealsAvailableLabel;
@synthesize asyncImageView;
@synthesize distanceLabel;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [distanceLabel release];
	[asyncImageView release];
	[dealsAvailableLabel release];
	[restaurantNameLabel release];
	[dealNameLabel release];
	[restaurantType release];
	[timeStampLabel release];

    [super dealloc];
}


@end
