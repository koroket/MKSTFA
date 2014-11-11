//
//  SearchSettingViewController.m
//  TFE
//
//  Created by sloot on 10/5/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SearchSettingViewController.h"
#import "NetworkCommunication.h"
#import "DraggableBackground.h"

@interface SearchSettingViewController ()

//buttons
@property (weak, nonatomic) IBOutlet UIButton *buttonRestaurants;
@property (weak, nonatomic) IBOutlet UIButton *buttonQuickEats;
@property (weak, nonatomic) IBOutlet UIButton *buttonCoffeeTea;
@property (weak, nonatomic) IBOutlet UIButton *buttonBreakfastBrunch;
@property (weak, nonatomic) IBOutlet UIButton *buttonDrinks;
@property (weak, nonatomic) IBOutlet UIButton *buttonNightLife;

//switches
@property (weak, nonatomic) IBOutlet UISwitch *switchRestaurants;
@property (weak, nonatomic) IBOutlet UISwitch *switchQuickEats;
@property (weak, nonatomic) IBOutlet UISwitch *switchDrinks;
@property (weak, nonatomic) IBOutlet UISwitch *switchNightlife;
@property (weak, nonatomic) IBOutlet UISwitch *switchCoffee;

@end

@implementation SearchSettingViewController
{
    UIButton *currentOnButton;
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
    
    // Get the stored data before the view loads
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"preferenceName"];
    
    [_switchRestaurants addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
      [_switchQuickEats addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
         [_switchDrinks addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
      [_switchNightlife addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
         [_switchCoffee addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"Search"] == nil)
    {
        //handle nil here
    }
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Search"]  isEqual: @"Restaurants"])
    {
        _switchRestaurants.on = YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Search"]  isEqual: @"QuickEats"])
    {
        _switchQuickEats.on = YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Search"]  isEqual: @"Drinks"])
    {
        _switchDrinks.on = YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Search"]  isEqual: @"Coffee"])
    {
        _switchCoffee.on = YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Search"]  isEqual: @"NightLife"])
    {
        _switchNightlife.on = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)setState:(id)sender
{
//    if (_switchRestaurants.on == YES)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:@"Restaurants" forKey:@"Search"];
//    }
//    else if (_switchQuickEats.on == YES)
//    {
//        yelpSearchTerm = @"QuickEats";
//    }
//    else if (_switchDrinks.on == YES)
//    {
//        yelpSearchTerm = @"Drinks";
//    }
//    else if (_switchCoffee.on == YES)
//    {
//        yelpSearchTerm = @"Coffee";
//    }
//    else if (_switchNightlife.on == YES)
//    {
//        yelpSearchTerm = @"NightLife";
//    }
    
    //[[NSUserDefaults standardUserDefaults] setObject:yelpSearchTerm forKey:@"YelpSearchTerm"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveContent
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yelpSearchTerm = @"";


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
    if ([segue.identifier isEqualToString:@"ToMapView"] == YES)
    {
        [self saveContent];
    }
}

- (IBAction)unwindSegueToSwiping:(UIStoryboardSegue *)unwindSegue
{
    //UIViewController* sourceViewController = unwindSegue.sourceViewController;
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
