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

@property (nonatomic, strong) IBOutlet UITextField *locationField;
@property (nonatomic, strong) IBOutlet UITextField *itemField;
@property (nonatomic)NSArray *pickerData;

@end

@implementation SearchSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //initialize the data for the UIPicke
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


-(NSString*)stringfix:(NSString*) str
{
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return temp;
    
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
    if ([segue.identifier isEqualToString:@"Save"])
    {
        //Save the values of the search boxes to the singleton
        //The number of desired locations
        [NetworkCommunication sharedManager].intYelpNumberOfLocations = 20;
        
        //The location
        [NetworkCommunication sharedManager].stringYelpLocation = [self stringfix:self.locationField.text];
        //The search term (food, bars, movie, etc)
        
    }
}

@end
