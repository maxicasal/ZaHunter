//
//  MapViewContainer.m
//  ZaFinder
//
//  Created by Bradley Walker on 10/15/14.
//  Copyright (c) 2014 BlackSummerVentures. All rights reserved.
//

#import "MapViewController.h"
#import "Pizzeria.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeAnnotations];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)loadMap
{
    [self makeAnnotations];
}

- (void) makeAnnotations
{
    NSMutableArray *pizzeriasArray = [self.delegate getPizzerias];
    for (Pizzeria *pizzeria in pizzeriasArray) {
//        Pizzeria *pizzeria = [Pizzeria new];

        CLLocationCoordinate2D coord;
        coord.latitude = pizzeria.pizzeriaPlacemark.location.coordinate.latitude;
        coord.longitude = pizzeria.pizzeriaPlacemark.location.coordinate.longitude;

        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.title = pizzeria.name;
        point.coordinate = coord;

        [self.mapView addAnnotation:point];
    }

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];

    if (annotation == mapView.userLocation)
    {
        return nil;
    }

    pin.image = [UIImage imageNamed:@"pizzaiconsmall"];
    pin.canShowCallout = YES;
    pin.centerOffset = CGPointMake(0, 0);
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];


    return pin;
}

@end
