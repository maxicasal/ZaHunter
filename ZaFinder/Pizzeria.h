//
//  Pizzeria.h
//  ZaFinder
//
//  Created by Bradley Walker on 10/15/14.
//  Copyright (c) 2014 BlackSummerVentures. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Pizzeria : NSObject

@property NSString *name;
@property NSString *starRating;
@property MKPlacemark *pizzeriaPlacemark;
@property NSString *phoneNumber;
@property NSURL *url;
@property NSTimeInterval etaByFoot;
@property NSTimeInterval etaByCar;
@property float distance;
@property float foot;
@property float car;

+ (Pizzeria *)createPizzeria:(MKMapItem *)pizzeriaMapItem:(CLLocation *)location:(CLPlacemark *)locationPlacemark;

@end
