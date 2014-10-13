//
//  SearchSettingViewController.m
//  TFE
//
//  Created by sloot on 10/5/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SearchSettingViewController.h"

@interface SearchSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *numberField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UITextField *itemField;


@end

@implementation SearchSettingViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Save"]) {
		[[NSUserDefaults standardUserDefaults] setObject:self.locationField.text forKey:@"location"];
		[[NSUserDefaults standardUserDefaults] setObject:self.numberField.text forKey:@"number"];
		[[NSUserDefaults standardUserDefaults] setObject:self.itemField.text forKey:@"item"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}
-(NSString*)stringer:(NSString*) str
{
    NSString* temp = @"";
    for(int i = 0; i < str.length; i++)
    {
    }
    return temp;
}

@end
