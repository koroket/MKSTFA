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

@end

@implementation SearchSettingViewController

#pragma message "Remove empty method stubs"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

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
    if ([segue.identifier isEqualToString:@"Restaurants"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Restaurants";
    }
    else if ([segue.identifier isEqualToString:@"QuickEats"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"QuickEats";
    }
    else if ([segue.identifier isEqualToString:@"CoffeeTea"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"CoffeeTea";
    }
    else if ([segue.identifier isEqualToString:@"BreakfastBrunch"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"BreakfastBrunch";
    }
    else if ([segue.identifier isEqualToString:@"Drinks"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Drinks";
    }
    else if ([segue.identifier isEqualToString:@"NightLife"])
    {
        [NetworkCommunication sharedManager].stringYelpSearchTerm = @"NightLife";
    }
    [NetworkCommunication sharedManager].intYelpNumberOfLocations = 20;
}

@end
