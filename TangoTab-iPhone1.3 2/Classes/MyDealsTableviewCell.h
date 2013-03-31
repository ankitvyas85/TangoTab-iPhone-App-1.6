//
//  MyDealsTableviewCell.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 06/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyDealsTableviewCell : UITableViewCell {

	IBOutlet UILabel *businessNameLable;
	IBOutlet UILabel *dealName;
	IBOutlet UILabel *businessDateLable;
	IBOutlet UIImageView *businessImageView;
}
@property (nonatomic, retain) IBOutlet UILabel *businessNameLable;
@property (nonatomic, retain) IBOutlet UILabel *businessDateLable;
@property (nonatomic, retain) IBOutlet UIImageView *businessImageView;
@property (nonatomic, retain) IBOutlet UILabel *dealName;
@end
