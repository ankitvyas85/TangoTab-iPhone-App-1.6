//
//  AddressAnnotation.h
//  TangoTab
//
//  Created by Hiteshwar Vadlamudi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : NSObject<MKAnnotation> {

	CLLocationCoordinate2D _coordinate;
	NSString*              _title;
	NSString *_subTitle;
	NSUInteger pinID;

}
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title andID:(NSUInteger)pin subTitle:(NSString *)subTitle;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;

@property (nonatomic) 	NSUInteger pinID;


@end
