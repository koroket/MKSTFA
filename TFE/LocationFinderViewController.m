//
//  LocationFinderViewController.m
//  TFE
//
//  Created by Luke Solomon on 10/20/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "LocationFinderViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationFinderViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldLocation;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)buttonCurrentLocation:(UIButton *)sender;

@end

@implementation LocationFinderViewController {
    
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //LocationManager stuff
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [manager requestWhenInUseAuthorization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


}

// ===== ===== ===== ===== =====
#pragma mark - button
// ===== ===== ===== ===== =====

- (IBAction)buttonCurrentLocation:(UIButton *)sender
{
    NSLog(@"anything");
    
    [manager startUpdatingLocation];
    
}

// ===== ===== ===== ===== =====
#pragma mark - locations
// ===== ===== ===== ===== =====

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
    NSLog(@"Location: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
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
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,
                                                                 currentLocation.coordinate.longitude);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    
    [self.mapView setRegion:region animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end