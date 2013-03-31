

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

@interface ActivityIndicatorView : UIView {
	UIActivityIndicatorView *activityIndicator;
}

- (id)initCentered;
- (void)removeActivityIndicator;

@property(nonatomic,retain) UIActivityIndicatorView *activityIndicator;
- (void)adjustFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame label: (NSString *)theLabel;
@end
