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

- (IBAction)buttonCurrentLocation:(UIButton *)sender;
- (IBAction)buttonStopUpdatingLocation:(UIButton *)sender;

@end

@implementation LocationFinderViewController
{
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

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    NSLog(@"current Location: %@", currentLocation);
//
//    
//    // Map View Stuff
//    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,
//                                                                 currentLocation.coordinate.longitude);
//    
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
//    
//    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
//    
//    [self.mapView setRegion:region animated:YES];
//    
//    // Singleton
//    [NetworkCommunication sharedManager].stringYelpLocation = [NSString stringWithFormat:(@"%f,%f"),
//                                                               currentLocation.coordinate.latitude,
//                                                               currentLocation.coordinate.longitude];
//    
//    // Sets the pin
//    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//    
//    [annotation setCoordinate:_mapView.centerCoordinate];
//    [annotation setTitle:@"Title"]; //You can set the subtitle too
//    [self.mapView addAnnotation:annotation];
//}

 
- (void)viewDidLoad
{
#pragma message "Use YES instead of true"
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - viewDidLoad - Start");}

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //LocationManager stuff
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (currentLocation == nil)
    {
        [manager requestWhenInUseAuthorization];
        [manager startUpdatingLocation];
    }
    else
    {
        [manager stopUpdatingLocation];
    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - viewDidLoad - Finished");}
}

#pragma mark - button
/**
 * --------------------------------------------------------------------------
 * Buttons
 * --------------------------------------------------------------------------
 */

- (IBAction)buttonCurrentLocation:(UIButton *)sender
{
    [manager startUpdatingLocation];
}

- (IBAction)buttonStopUpdatingLocation:(UIButton *)sender
{
    [manager stopUpdatingLocation];
}

#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */
- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!:(");
}

//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations
//{
//    [locations lastObject];
//    
//    
//}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
#pragma message "Use YES instead of true"

    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - didUpdateToLocation - Start");}

    NSLog(@"Location: %@", newLocation);
    
    currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        //self.textFieldLocation.text = [NSString stringWithFormat:@" ";
    }
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error)
    {
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            self.address.text = [NSString stringWithFormat:@"%@ %@\n%@\n %@\n%@%@",
                                           placemark.subThoroughfare,
                                           placemark.thoroughfare,
                                           placemark.postalCode,
                                           placemark.locality,
                                           placemark.administrativeArea,
                                           placemark.country];
        }
        else
        {
            NSLog(@"%@",error.debugDescription);
        }
        
    }];
    // Map View Stuff
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,
                                                                 currentLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:YES];
    
    // Sets the pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:currentLocation.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    // Singleton
#pragma message "Why are you storing GeoLocations as strings? It would be nicer to store them with their actual type and let the NetworkCommunication class translate them into strings before talking to the server"
    [NetworkCommunication sharedManager].stringYelpLocation = [NSString stringWithFormat:(@"%f,%f"),
                                                               currentLocation.coordinate.latitude,
                                                               currentLocation.coordinate.longitude];
    
    [NetworkCommunication sharedManager].stringCurrentLatitude = [NSString stringWithFormat:(@"%f"),
                                                                    currentLocation.coordinate.latitude];
    
    [NetworkCommunication sharedManager].stringCurrentLongitude = [NSString stringWithFormat:(@"%f"),
                                                               currentLocation.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - didUpdateToLocation - Finished");}
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - prepareForSegue - Start");}

    if ([segue.identifier isEqualToString:@"Save"])
    {
        
    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - prepareForSegue - Finished");}
}

- (IBAction)unwind:(id)sender
{
#pragma message "Instead of repeating the following line again and again it would be nicer to define a helper function that gets called with a string; that would allow you to change the behavior of that funtion in one single place"
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - unwind - Start");}

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"LocationFinder - unwind - Finished");}
}

@end