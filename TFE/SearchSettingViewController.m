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

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([NetworkCommunication sharedManager].stringYelpSearchTerm == @"Restaurants")
    {
        _switchRestaurants.on = YES;
    }
    else if ([NetworkCommunication sharedManager].stringYelpSearchTerm == @"QuickEats")
    {
        _switchRestaurants.on = YES;
    }
    else if ([NetworkCommunication sharedManager].stringYelpSearchTerm == @"Drinks")
    {
        _switchRestaurants.on = YES;
    }
    else if ([NetworkCommunication sharedManager].stringYelpSearchTerm == @"BreakfastBrunch")
    {
        _switchRestaurants.on = YES;
    }
    else if ([NetworkCommunication sharedManager].stringYelpSearchTerm == @"NightLife")
    {
        _switchRestaurants.on = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
        if (_switchRestaurants.on == YES)
        {
            [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Restaurants";
        }
        else if (_switchQuickEats.on == YES)
        {
            [NetworkCommunication sharedManager].stringYelpSearchTerm = @"QuickEats";
        }
        else if (_switchDrinks.on == YES)
        {
            [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Drinks";
        }
        else if (_switchCoffee.on == YES)
        {
            [NetworkCommunication sharedManager].stringYelpSearchTerm = @"BreakfastBrunch";
        }
        else if (_switchNightlife.on == YES)
        {
            [NetworkCommunication sharedManager].stringYelpSearchTerm = @"NightLife";
        }
    }
    [NetworkCommunication sharedManager].intYelpNumberOfLocations = 20;
}

- (IBAction)unwindSegueToSwiping:(UIStoryboardSegue *)unwindSegue
{
    if (_switchRestaurants.on == YES)
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Restaurants";
    }
    else if (_switchQuickEats.on == YES)
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"QuickEats";
    }
    else if (_switchDrinks.on == YES)
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Drinks";
    }
    else if (_switchCoffee.on == YES)
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"BreakfastBrunch";
    }
    else if (_switchNightlife.on == YES)
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"NightLife";
    }

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
                     animations:^{
                         // Grow!
                         destinationViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         destinationViewController.view.center = originalCenter;
                     }
                     completion:^(BOOL finished){
                         [destinationViewController.view removeFromSuperview]; // remove from temp super view
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
                     }];
}

@end
