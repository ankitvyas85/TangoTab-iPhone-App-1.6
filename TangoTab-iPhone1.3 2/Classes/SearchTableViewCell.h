//
//  SearchTableViewCell.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 06/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SearchTableViewCell : UITableViewCell {

	IBOutlet UILabel *restaurantNameLabel;
	IBOutlet UILabel *dealNameLabel;
	IBOutlet UILabel *restaurantType;
	IBOutlet UILabel *timeStampLabel;
	IBOutlet UIImageView *restaurantImage;
	IBOutlet UILabel *dealsAvailableLabel;
	
	IBOutlet AsyncImageView *asyncImageView;
}

@property(nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *dealNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *restaurantType;
@property(nonatomic, retain) IBOutlet UILabel *timeStampLabel;
@property(nonatomic, retain) IBOutlet UIImageView *restaurantImage;
@property(nonatomic, retain) IBOutlet UILabel *dealsAvailableLabel;
@property(nonatomic, retain) IBOutlet AsyncImageView *asyncImageView;

@end
