//
//  PlacesTableViewCell.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewCell.h"


@implementation PlacesTableViewCell

@synthesize restaurantNameLabel;
@synthesize dealNameLabel;
@synthesize drivingDistanceLabel;
@synthesize restaurantType;
@synthesize timeStampLabel;
@synthesize restaurantImage;
@synthesize dealsAvailableLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[dealsAvailableLabel release];
	[restaurantNameLabel release];
	[dealNameLabel release];
    [drivingDistanceLabel release];
	[restaurantType release];
	[timeStampLabel release];
	[restaurantImage release];
    [super dealloc];
}


@end
