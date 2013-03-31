

#import "ImageCacheObject.h"

@implementation ImageCacheObject

@synthesize size;
@synthesize timeStamp;
@synthesize image;

-(id)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage{
    if (self = [super init]) {
        size = sz;
        timeStamp = [[NSDate date] retain];
        image = [anImage retain];
    }
    return self;
}

-(void)resetTimeStamp {
    [timeStamp release];
    timeStamp = [[NSDate date] retain];
}

-(void) dealloc {
    [timeStamp release];
    [image release];
    [super dealloc];
}

@end
