//
//  CustomCell.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearMeCustomCell.h"

@implementation NearMeCustomCell
@synthesize restaurantNameLabel,dealNameLabel,drivingDistanceLabel,restaurantType,timeStampLabel,dealsAvailableLabel,asyncimageview;

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
    [restaurantType release];
    [asyncimageview release];
	[restaurantNameLabel release];
    [dealNameLabel release];
    [drivingDistanceLabel release];
    [restaurantType release];
    [timeStampLabel release];
    [dealsAvailableLabel release];
    [super dealloc];
}

@end
