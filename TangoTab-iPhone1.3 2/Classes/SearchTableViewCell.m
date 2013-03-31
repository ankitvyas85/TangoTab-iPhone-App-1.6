//
//  SearchTableViewCell.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 06/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchTableViewCell.h"


@implementation SearchTableViewCell
@synthesize restaurantNameLabel;
@synthesize dealNameLabel;
@synthesize restaurantType;
@synthesize timeStampLabel;
@synthesize restaurantImage;
@synthesize dealsAvailableLabel;
@synthesize asyncImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[asyncImageView release];
	[dealsAvailableLabel release];
	[restaurantNameLabel release];
	[dealNameLabel release];
	[restaurantType release];
	[timeStampLabel release];
	[restaurantImage release];
    [super dealloc];
}


@end
