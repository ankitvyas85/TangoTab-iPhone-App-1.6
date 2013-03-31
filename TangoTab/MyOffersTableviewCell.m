//
//  MyOffersTableviewCell.m
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyOffersTableviewCell.h"

@implementation MyOffersTableviewCell
@synthesize business_name,deal_name,dateandtime,conformationId,asyncImageView,backgroundImage;
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
    [backgroundImage release];
    [business_name release];
	[asyncImageView release];
	[deal_name release];
	[dateandtime release];
	[conformationId release];
    
    [super dealloc];
}


@end
