//
//  SearchSettingViewController.m
//  TFE
//
//  Created by sloot on 10/5/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SearchSettingViewController.h"
#import "NetworkCommunication.h"

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
    if ([segue.identifier isEqualToString:@"Next"] == YES)
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

@end
