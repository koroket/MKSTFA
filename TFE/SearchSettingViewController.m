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

@property (nonatomic, strong) IBOutlet UITextField *numberField;
@property (nonatomic, strong) IBOutlet UITextField *locationField;
@property (nonatomic, strong) IBOutlet UITextField *itemField;
@property (nonatomic, weak) IBOutlet UIPickerView *yelpOptionPicker;

@property (nonatomic)NSArray *pickerData;

    
@end

@implementation SearchSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize the data for the UIPicker
    _pickerData = @[@"Food", @"Bars", @"Clubs", @"Lauren is amazing"];
    
    self.yelpOptionPicker.dataSource = self;
    self.yelpOptionPicker.delegate = self;
    
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

#pragma mark - Picker Methods
/**
 * --------------------------------------------------------------------------
 * Picker Methods
 * --------------------------------------------------------------------------
 */

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
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



@end
