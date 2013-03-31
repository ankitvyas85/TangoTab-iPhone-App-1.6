

//
// Code heavily lifted from here:
// http://www.markj.net/iphone-asynchronous-table-image/
//

#import <UIKit/UIKit.h>


@interface AsyncImageView : UIView {
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *urlString; // key for image cache dictionary
	int x;
	int y;
}
@property(nonatomic, assign) int x;
@property(nonatomic, assign) int y;
-(void)loadImageFromURL:(NSURL*)url;

@end
