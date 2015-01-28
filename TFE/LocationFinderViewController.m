//
//  LocationFinderViewController.m
//  TFE
//
//  Created by Luke Solomon on 10/20/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "LocationFinderViewController.h"
#import "MBProgressHUD.h"
#import "NetworkCommunication.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationFinderViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldLocation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *address;
@end

@implementation LocationFinderViewController {
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad {
    [super viewDidLoad];
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
}

#pragma mark - Locations
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
    NSLog(@"Location: %@", newLocation);
    currentLocation = newLocation;
    if (currentLocation != nil) {
        //self.textFieldLocation.text = [NSString stringWithFormat:@" ";
    }
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            self.address.text = [NSString stringWithFormat:@"%@ %@\n%@, %@, %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
        } else {
            NSLog(@"%@",error.debugDescription);
        }
    }];
    // Map View Stuff
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.009, 0.009);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:NO];
    // Sets the pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:currentLocation.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    // Singleton
    [NetworkCommunication sharedManager].stringYelpLocation = [NSString stringWithFormat:(@"%f,%f"), currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    [NetworkCommunication sharedManager].stringCurrentLatitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.latitude];
    [NetworkCommunication sharedManager].stringCurrentLongitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.longitude];
    [manager stopUpdatingLocation];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SaveLocation"]) {
        
    }
}

- (IBAction)unwindToSearchSettings:(UIStoryboardSegue *)unwindSegue {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    //UIViewController* sourceViewController = unwindSegue.sourceViewController;
}

@end
