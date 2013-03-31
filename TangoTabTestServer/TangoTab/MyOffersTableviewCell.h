//
//  MyOffersTableviewCell.h
//  TangoTab
//
//  Created by Sirisha G on 12/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MyOffersTableviewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *business_name,*deal_name,*dateandtime,*conformationId;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet AsyncImageView *asyncImageView;

@end
