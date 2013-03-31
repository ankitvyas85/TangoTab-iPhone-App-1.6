//
//  ReviewTableViewCell.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 08/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReviewTableViewCell : UITableViewCell {

	IBOutlet  UIImageView *reviewImageView;
	IBOutlet  UIImageView *ratingImageView;
	IBOutlet UILabel  *userCommentLabel;
}
@property (nonatomic, retain) IBOutlet  UIImageView *reviewImageView;
@property (nonatomic, retain) IBOutlet  UIImageView *ratingImageView;
@property (nonatomic, retain) IBOutlet  UILabel *userCommentLabel;


@end
