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

@implementation SavedCardsDetailViewController
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadMyData];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.mapView addGestureRecognizer:singleTapGestureRecognizer];
    
    [manager requestWhenInUseAuthorization];
    [manager startUpdatingLocation];
    
}

-(void)loadMyData
{
    self.priceLabel.text = [NetworkCommunication sharedManager].currentCard.price;
    self.distLabel.text = [NetworkCommunication sharedManager].currentCard.distance;
    self.ratingLabel.text = [NetworkCommunication sharedManager].currentCard.rating;
    self.categoryLabel.text = [NetworkCommunication sharedManager].currentCard.categories;
    self.hoursLabel.text = [NetworkCommunication sharedManager].currentCard.hours;
    self.placesLabel.text = [NetworkCommunication sharedManager].currentCard.name;
    self.imageview.image = [UIImage imageWithData:[NetworkCommunication sharedManager].currentCard.image];
    
    
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"Segue");
    [self performSegueWithIdentifier: @"mapViewSegue" sender:self];
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

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    

    
    // Map View Stuff
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.009, 0.009);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:YES];
    
    // Sets the pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:currentLocation.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    [manager stopUpdatingLocation];
    
}


#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    
    if ([segue.identifier isEqual: @"mapViewSegue"])
    {
        
    }
    
}

@end
