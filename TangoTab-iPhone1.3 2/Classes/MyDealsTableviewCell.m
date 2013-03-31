//
//  MyDealsTableviewCell.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 06/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDealsTableviewCell.h"


@implementation MyDealsTableviewCell
@synthesize businessNameLable,businessDateLable,businessImageView,dealName;
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
	[dealName release];
	[businessDateLable release];
	[businessNameLable release];
	[businessImageView release];
    [super dealloc];
}


@end
