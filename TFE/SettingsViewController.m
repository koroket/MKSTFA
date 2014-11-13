//
//  SettingsViewController.m
//  TFE
//
//  Created by Luke Solomon on 11/11/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SettingsViewController.h"
#import "NetworkCommunication.h"
#import "DraggableBackground.h"
#import "MBProgressHUD.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface SettingsViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavigationItem;

@end


@implementation SettingsViewController
{
    //location stuff
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLLocation *currentLocation;
    
    NSArray *_pickerData;

}

#pragma mark - Init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    //initialize picker data
    _pickerData = @[@"Restaurants", @"Quick Eats", @"Bars", @"NightLife", @"Coffee & Breakfast"];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

#pragma mark - Picker
/**
 * --------------------------------------------------------------------------
 * Picker
 * --------------------------------------------------------------------------
 */

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    return _pickerData[row];
}

// Capture the picker view selection
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    //[NetworkCommunication sharedManager].stringYelpSearchTerm = _pickerData[row];
    
    [[NSUserDefaults standardUserDefaults] setObject:_pickerData[row] forKey:@"Search Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"The current selection is %@",_pickerData[row]);
}

#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Location: %@", newLocation);
    currentLocation = newLocation;
    if (currentLocation != nil)
    {
        //self.textFieldLocation.text = [NSString stringWithFormat:@" ";
    }
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil)
         {

         }
         else
         {
             NSLog(@"%@",error.debugDescription);
         }
         
     }];
    
    
    
    // Map View Stuff
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:YES];
    
    // Sets the pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:currentLocation.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    // NSUserDefaults
    
    //currentLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"User Location"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLocation forKey:@"User Location"];

    
    
//    [NetworkCommunication sharedManager].stringYelpLocation = [NSString stringWithFormat:(@"%f,%f"),
//                                                               currentLocation.coordinate.latitude,
//                                                               currentLocation.coordinate.longitude];
//    
//    [NetworkCommunication sharedManager].stringCurrentLatitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.latitude];
//    
//    [NetworkCommunication sharedManager].stringCurrentLongitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.longitude];
    
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

}

- (IBAction)unwindSegueToSwiping:(UIStoryboardSegue *)unwindSegue
{
    //code for custom unwind segue
    UIViewController *sourceViewController = unwindSegue.sourceViewController;
    UIViewController *destinationViewController = unwindSegue.destinationViewController;
    
    
    // Add the destination view as a subview, temporarily
    [sourceViewController.view addSubview:destinationViewController.view];
    
    // Transformation start scale
    destinationViewController.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
    
    // Store original centre point of the destination view
    CGPoint originalCenter = destinationViewController.view.center;
    // Set center to start point of the button
    //destinationViewController.view.center = self.originatingPoint;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         // Grow!
                         destinationViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         destinationViewController.view.center = originalCenter;
                     }
                     completion:^(BOOL finished) {
                         [destinationViewController.view removeFromSuperview]; // remove from temp super view
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
                     }];
}


@end
