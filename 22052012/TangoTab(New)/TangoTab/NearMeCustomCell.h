//
//  CustomCell.h
//  TangoTab
//
//  Created by Gopal Krishna U on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface NearMeCustomCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dealNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *drivingDistanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *restaurantType;
@property (nonatomic, retain) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, retain) IBOutlet UILabel *dealsAvailableLabel;
@property (nonatomic, retain) IBOutlet AsyncImageView *asyncimageview;
@end
