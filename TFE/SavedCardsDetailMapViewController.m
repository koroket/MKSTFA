//
//  SavedCardsDetailMapViewController.m
//  TFE
//
//  Created by Luke Solomon on 11/14/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SavedCardsDetailMapViewController.h"
#import "MBProgressHUD.h"
#import "NetworkCommunication.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SavedCardsDetailMapViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end


@implementation SavedCardsDetailMapViewController {
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
    NSString *theAddress;
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //LocationManager stuff
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    if (currentLocation == nil) {
        [manager requestWhenInUseAuthorization];
        [manager startUpdatingLocation];
    } else {
        [manager stopUpdatingLocation];
    }
    self.address.text = [NSString stringWithFormat:@"%@\n%@, %@, %@", [NetworkCommunication sharedManager].currentCard.address, [NetworkCommunication sharedManager].currentCard.city, [NetworkCommunication sharedManager].currentCard.state, [NetworkCommunication sharedManager].currentCard.zipcode ];
    self->theAddress = [NSString stringWithFormat:@"%@/%@/%@/%@", [NetworkCommunication sharedManager].currentCard.address, [NetworkCommunication sharedManager].currentCard.city, [NetworkCommunication sharedManager].currentCard.state, [NetworkCommunication sharedManager].currentCard.zipcode ];
}

#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!:(");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //Geocode the Address of the restaurant
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self->theAddress completionHandler:^(NSArray* placemarks, NSError* error) {
         for (CLPlacemark* aPlacemark in placemarks) {
             // Process the placemark.
             NSString *latDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.latitude];
             NSString *lngDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.longitude];
             //lblDestinationLat.text = latDest1;
             //lblDestinationLng.text = lngDest1;
             //NSLog(@"lat: %@, lng: %@", latDest1, lngDest1);
             //Make a 2dCoordinate
             CLLocationCoordinate2D RestaurantLocation = CLLocationCoordinate2DMake(aPlacemark.location.coordinate.latitude, aPlacemark.location.coordinate.longitude);
             // Map View Stuff
             MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
             MKCoordinateRegion thisRegion = MKCoordinateRegionMake(RestaurantLocation, span);
             [self.mapView setRegion:thisRegion animated:NO];
             // Sets the pin
             MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
             [annotation setCoordinate:RestaurantLocation];
             [annotation setTitle:[NetworkCommunication sharedManager].currentCard.address];
             [self.mapView addAnnotation:annotation];
         }
     }];
    [self->manager stopUpdatingLocation];
}

@end