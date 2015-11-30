//
//  SavedCardsDetailViewController.m
//  TFE
//
//  Created by Luke Solomon on 11/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//
#import "SavedCardsDetailViewController.h"
#import "NetworkCommunication.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SavedCardsDetailViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *placesLabel;
@property (strong, nonatomic) IBOutlet UILabel *distLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SavedCardsDetailViewController {
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
    [self loadMyData];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.mapView addGestureRecognizer:singleTapGestureRecognizer];
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
    self->theAddress = [NSString stringWithFormat:@"%@/%@/%@/%@", [NetworkCommunication sharedManager].currentCard.address, [NetworkCommunication sharedManager].currentCard.city, [NetworkCommunication sharedManager].currentCard.state, [NetworkCommunication sharedManager].currentCard.zipcode ];
}

-(void)loadMyData {
    //set the title of the View Controller to the place's name
    self.navigationItem.title = [NetworkCommunication sharedManager].currentCard.name;
    //Load the information for the card from Navigation controller
    self.imageview.image = [UIImage imageWithData:[NetworkCommunication sharedManager].currentCard.image];
    //Name
    if ([NetworkCommunication sharedManager].currentCard.name != nil) {
        self.placesLabel.text = [NetworkCommunication sharedManager].currentCard.name;
    } else {
        self.placesLabel.text = @" ";
    }
    //Distance
    if ([NetworkCommunication sharedManager].currentCard.distance != nil) {
        self.distLabel.text = [NetworkCommunication sharedManager].currentCard.distance;
    } else {
        self.distLabel.text = @" ";
    }
    //Price
    if ([NetworkCommunication sharedManager].currentCard.price != nil) {
        self.priceLabel.text = [NetworkCommunication sharedManager].currentCard.price;
    } else {
        self.priceLabel.text = @" ";
    }
    //Rating
    if ([NetworkCommunication sharedManager].currentCard.rating != nil) {
        self.ratingLabel.text = [NetworkCommunication sharedManager].currentCard.rating;
    } else {
        self.ratingLabel.text = @" ";
    }
    //Categories
    if ([NetworkCommunication sharedManager].currentCard.categories != nil) {
        self.categoryLabel.text = [NetworkCommunication sharedManager].currentCard.categories;
    } else {
        self.categoryLabel.text = @" ";
    }
    //Hours
    if ([NetworkCommunication sharedManager].currentCard.hours != nil) {
        self.hoursLabel.text = [NetworkCommunication sharedManager].currentCard.hours;
    } else {
        self.hoursLabel.text = @" ";
    }
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    //NSLog(@"Segue");
    [self performSegueWithIdentifier: @"mapViewSegue" sender:self];
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
             //NSString *latDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.latitude];
             //NSString *lngDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.longitude];
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

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual: @"mapViewSegue"]) {
        
    }
    
}

@end
