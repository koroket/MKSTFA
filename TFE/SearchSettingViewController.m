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

@property (strong, nonatomic) IBOutlet UITextField *numberField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UITextField *itemField;

@end

@implementation SearchSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Save"])
    {
        //Save the values of the search boxes to the singleton
        //The location
        [NetworkCommunication sharedManager].stringYelpLocation = self.locationField.text;
        //The number of desired locations
        [NetworkCommunication sharedManager].intYelpNumberOfLocations = self.numberField.text.intValue;
        //The search term (food, bars, movie, etc)
        [NetworkCommunication sharedManager].stringYelpSearchTerm = self.itemField.text;
    }
}

-(NSString*)stringfix:(NSString*) str
{
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return temp;
}


@end
