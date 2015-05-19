
#import "RootViewController.h"
#import "Pizzeria.h"
#import "MapViewController.h"
#import "PizzeriasDelegate.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITabBarDelegate, MKMapViewDelegate, PizzeriasDelegate>
@property CLLocationManager *myLocationManager;
@property NSMutableArray *pizzerias;
@property CLLocation *myCurrentLocation;
@property CLPlacemark *myCurrentLocationPlacemark;
@property (strong, nonatomic) IBOutlet UIView *mapContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapContainerRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapContainerLeftConstraint;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UITabBarItem *listTabBarButton;
@property (strong, nonatomic) IBOutlet UITabBarItem *mapTabBarButton;
@property MapViewController *mapViewController;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myLocationManager = [CLLocationManager new];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;

    [self.myLocationManager startUpdatingLocation];
    self.pizzerias = [[NSMutableArray alloc] init];

    self.tableView.delegate = self;

    self.mapContainerLeftConstraint.constant = self.mapContainer.frame.size.width * 2;
    self.mapContainerRightConstraint.constant = self.mapContainer.frame.size.width * 2;
}

- (NSMutableArray *)getPizzerias
{
    return self.pizzerias;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            NSLog(@"Location found. Reverse geocoding...");
            [self reverseGeocode:location];
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void) reverseGeocode:(CLLocation *)location
{
    CLGeocoder *geocode = [CLGeocoder new];
    [geocode reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placemark = placemarks.firstObject;
        self.myCurrentLocation = placemark.location;
        self.myCurrentLocationPlacemark = placemark;
        [self findPizzaPlaces:placemark.location];
    }];
}

- (void) findPizzaPlaces:(CLLocation *)location
{

    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.1, .1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        for (MKMapItem *mapItem in mapItems) {
//            if (self.pizzerias.count < 4)
//            {
                [self addETA:mapItem];
                NSLog(@"Pizza joint added to list");
//            }
        }
    }];
}

-(void)addETA:(MKMapItem *)mapItem
{
//    NSTimeInterval etaByFoot;
    MKDirectionsRequest *requestFootTravel = [[MKDirectionsRequest alloc] init];
    MKPlacemark *tempPlacemark = [[MKPlacemark alloc] initWithPlacemark:self.myCurrentLocationPlacemark];
    MKMapItem *locationMapItem = [[MKMapItem alloc] initWithPlacemark:tempPlacemark];
    requestFootTravel.source = locationMapItem;
    requestFootTravel.destination = mapItem;

    MKDirections *directionsByFoot =
    [[MKDirections alloc] initWithRequest:requestFootTravel];
    [requestFootTravel setTransportType:MKDirectionsTransportTypeWalking];
    [directionsByFoot calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error)
     {
         if (self.pizzerias.count < 4)
         {
             Pizzeria *pizzeria = [Pizzeria createPizzeria:mapItem:self.myCurrentLocation:self.myCurrentLocationPlacemark];
             pizzeria.etaByFoot = response.expectedTravelTime;
             [self.pizzerias addObject:pizzeria];
             [self.tableView reloadData];
         }
     }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellID" forIndexPath:indexPath];
    Pizzeria *pizzaPlace = [self.pizzerias objectAtIndex:indexPath.row];
    cell.textLabel.text = pizzaPlace.name;
    double etaCorrection = pizzaPlace.etaByFoot / 60;
    cell.detailTextLabel.text = [[NSString stringWithFormat:@"%0.0f",etaCorrection] stringByAppendingString:@" minutes away"];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pizzerias.count;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"There was an issue with finding your location.");
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [UIView animateWithDuration:.35 animations:^{
        if (item.tag == 0)
        {
            self.mapContainerLeftConstraint.constant = self.mapContainer.frame.size.width * 2;
            self.mapContainerRightConstraint.constant = self.mapContainer.frame.size.width * 2;
        }
        else if (item.tag == 1)
        {
            [self.mapViewController loadMap];
            self.mapContainerLeftConstraint.constant = 0;
            self.mapContainerRightConstraint.constant = 0;
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapViewSegue"]) {
        self.mapViewController = [segue destinationViewController];
        self.mapViewController.delegate = self;
    }
}

@end
