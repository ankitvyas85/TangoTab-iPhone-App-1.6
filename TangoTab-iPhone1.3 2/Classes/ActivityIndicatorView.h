

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

@interface ActivityIndicatorView : UIView {
	UIActivityIndicatorView *activityIndicator;
//	UILabel *loadingLabel;
}

- (id)initCentered;
- (void)removeActivityIndicator;

@property(nonatomic,retain)UIActivityIndicatorView *activityIndicator;
//@property(nonatomic,retain)UILabel *loadingLabel;

- (void)adjustFrame:(CGRect)frame;

@end
