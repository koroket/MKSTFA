//
//  SettingsViewController.m
//  TFE
//
//  Created by Luke Solomon on 11/11/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SettingsViewController.h"
#import "NetworkCommunication.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SettingsViewController () <CLLocationManagerDelegate>

// properties
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavigationItem;
// IBOutlets
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UISlider *ratingSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;

@end

@implementation SettingsViewController {
    //location stuff
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLLocation *currentLocation;
    //Array
    NSArray *_pickerData;
}

- (IBAction)distanceChanged:(id)sender {
    NSLog([NSString stringWithFormat:@"%f",((UISlider*)sender).value]);
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",((UISlider*)sender).value*20.0] forKey:@"maxDistance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.distanceLabel.text = [NSString stringWithFormat:@"%f",((UISlider*)sender).value*20.0];
}

- (IBAction)ratingChanged:(id)sender {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",((UISlider*)sender).value*5.0] forKey:@"minRating"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    self.ratingLabel.text = [NSString stringWithFormat:@"%f",((UISlider*)sender).value*5.0];
}

#pragma mark - Init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad {
    [super viewDidLoad];
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
    //initialize picker data
    _pickerData = @[@"Restaurants", @"Food", @"Bars", @"NightLife", @"Shopping", @"Japanese", @"Chinese" , @"Automotive"];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.mapView addGestureRecognizer:singleTapGestureRecognizer];
    //This is the shittiest way possible to make this work...
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Restaurants"]) {
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Food"]) {
        [_pickerView selectRow:1 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Bars"]) {
        [_pickerView selectRow:2 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"NightLife"]) {
        [_pickerView selectRow:3 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Shopping"]) {
        [_pickerView selectRow:4 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Japanese"]) {
        [_pickerView selectRow:5 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Chinese"]) {
        [_pickerView selectRow:6 inComponent:0 animated:YES];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:(@"Yelp Search Term")]  isEqual: @"Automotive"]) {
        [_pickerView selectRow:7 inComponent:0 animated:YES];
    }

}

#pragma mark - Picker
/**
 * --------------------------------------------------------------------------
 * Picker
 * --------------------------------------------------------------------------
 */

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerData[row];
}

// Capture the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[NSUserDefaults standardUserDefaults] setObject:_pickerData[row] forKey:@"Yelp Search Term"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NetworkCommunication sharedManager].searchTermDidChange = true;
    NSLog(@"The current selection is %@",_pickerData[row]);
}

// Change the attributes of the text in the UIPicker
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:_pickerData[row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self performSegueWithIdentifier: @"mapViewSegue" sender:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %@", newLocation);
    currentLocation = newLocation;
    // Map View Stuff
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:YES];
    // Sets the pin
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:currentLocation.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    // NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.latitude) forKey:@"User Location Latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.longitude) forKey:@"User Location Longitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [manager stopUpdatingLocation];
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

- (IBAction)unwindSegueToSwiping:(UIStoryboardSegue *)unwindSegue {
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
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
         // Grow!
         destinationViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
         destinationViewController.view.center = originalCenter;
    } completion:^(BOOL finished) {
         [destinationViewController.view removeFromSuperview]; // remove from temp super view
         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
    }];
}


@end
