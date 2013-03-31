

#import "ActivityIndicatorView.h"


#define indicatorViewWidth	100.0f
#define indicatorViewHeight	25.0f

@implementation ActivityIndicatorView

@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    @try {
        if (self = [super initWithFrame:frame])
        {
            UIView *loadingView = [[UIView alloc] initWithFrame:frame];
            loadingView.backgroundColor=[UIColor darkGrayColor];
            loadingView.alpha=0.5;
            [self addSubview:loadingView];
            UILabel *lblFalse;
            lblFalse=[[UILabel alloc]initWithFrame:CGRectMake((320/2 - 80),(302/2 - 30),160,60)];
            lblFalse.font=[UIFont fontWithName:@"Verdana" size:20];
            lblFalse.textColor=[UIColor whiteColor];
            lblFalse.backgroundColor = [UIColor colorWithRed:0.957 green:0.486 blue:0.173 alpha:1.000];
            lblFalse.textAlignment=UITextAlignmentRight;
            lblFalse.layer.cornerRadius=10;
            lblFalse.layer.borderWidth=5.5;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	
            float grayComponents[4] = {255.0/255,255.0/255,255.0/255,1.0};
            lblFalse.layer.borderColor=CGColorCreate(colorSpace, grayComponents);
            CGColorSpaceRelease(colorSpace);
            
            
            [loadingView addSubview:lblFalse];
            [loadingView release];
            
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.frame = CGRectMake(10,15,30,30);
            activityIndicator.hidesWhenStopped = YES;
            [lblFalse addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            UILabel *lblLoadingLabel;
			
            lblLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 90, indicatorViewHeight)];
            lblLoadingLabel.text = @"Loading...";		//Loading label for other classess
            
            lblLoadingLabel.font = [UIFont systemFontOfSize:20];
            lblLoadingLabel.textColor = [UIColor whiteColor];
            lblLoadingLabel.backgroundColor = [UIColor clearColor];
            [lblFalse addSubview:lblLoadingLabel];
            [lblLoadingLabel release];
            [lblFalse release];
            return self;
            
        }
        else
            return self;
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"There is no response from the server at this time. (or) There is some problem ocuured from Application Execution" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
}

// designated initializer (for default centering behavior)
// use initWithFrame above if you want to set location
- (id)initCentered 
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect indicatorViewRect = screenRect;
	if (![super initWithFrame:indicatorViewRect])
	{
		return nil;
	}

    return [self initWithFrame:indicatorViewRect];
}

- (void)adjustFrame:(CGRect)frame {
	[self setFrame:frame];
}


- (void)removeActivityIndicator {
	[activityIndicator stopAnimating];
	[self removeFromSuperview];
}

- (void)dealloc {
	self.activityIndicator = nil;
    [super dealloc];
}


@end
