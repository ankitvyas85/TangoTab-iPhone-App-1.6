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
    MKPinAnnotationColor pinColor;
}

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subTitle;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;
@property (nonatomic) 	NSUInteger pinID;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title andID:(NSUInteger)pin subTitle:(NSString *)subTitle;
+ (NSString *)	reusableIdentifierforPinColor :(MKPinAnnotationColor)paramColor;



@end
