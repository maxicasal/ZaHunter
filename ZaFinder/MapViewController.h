//
//  MapViewContainer.h
//  ZaFinder
//
//  Created by Bradley Walker on 10/15/14.
//  Copyright (c) 2014 BlackSummerVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PizzeriasDelegate.h"

@interface MapViewController : UIViewController
@property NSMutableArray *pizzerias;
@property id<PizzeriasDelegate> delegate;

-(void)loadMap;
@end
