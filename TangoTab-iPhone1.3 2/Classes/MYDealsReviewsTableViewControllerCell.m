//
//  MYDealsReviewsTableViewControllerCell.m
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 11/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MYDealsReviewsTableViewControllerCell.h"


@implementation MYDealsReviewsTableViewControllerCell

@synthesize reviewImageView,userCommentLabel,ratingImageView;
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
	[reviewImageView release];
	[ratingImageView release];
	[userCommentLabel release];
    [super dealloc];
}



@end
