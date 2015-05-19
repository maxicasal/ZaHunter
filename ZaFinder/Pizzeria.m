//
//  Pizzeria.m
//  ZaFinder
//
//  Created by Bradley Walker on 10/15/14.
//  Copyright (c) 2014 BlackSummerVentures. All rights reserved.
//

#import "Pizzeria.h"

@implementation Pizzeria

+ (Pizzeria *)createPizzeria:(MKMapItem *)pizzeriaMapItem: (CLLocation *)location: (CLPlacemark *)locationPlacemark
{
    Pizzeria *pizzeria = [Pizzeria new];
    pizzeria.name = pizzeriaMapItem.name;
    pizzeria.pizzeriaPlacemark = pizzeriaMapItem.placemark;
    pizzeria.phoneNumber = pizzeriaMapItem.phoneNumber;
    pizzeria.url = pizzeriaMapItem.url;
    pizzeria.distance = [pizzeriaMapItem.placemark.location distanceFromLocation:location] / 1609.34;


    MKDirectionsRequest *requestFootTravel = [[MKDirectionsRequest alloc] init];
    MKPlacemark *tempPlacemark = [[MKPlacemark alloc] initWithPlacemark:locationPlacemark];
    MKMapItem *locationMapItem = [[MKMapItem alloc] initWithPlacemark:tempPlacemark];
    requestFootTravel.source = locationMapItem;
    requestFootTravel.destination = pizzeriaMapItem;

    MKDirections *directionsByFoot =
    [[MKDirections alloc] initWithRequest:requestFootTravel];
    [requestFootTravel setTransportType:MKDirectionsTransportTypeWalking];
    [directionsByFoot calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error)
    {
        pizzeria.etaByFoot = response.expectedTravelTime;
    }];
    return pizzeria;
}

@end
