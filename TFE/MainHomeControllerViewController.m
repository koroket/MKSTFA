//
//  MainHomeControllerViewController.m
//  TFE
//
//  Created by sloot on 10/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "MainHomeControllerViewController.h"
#import "GroupTableViewController.h"
@interface MainHomeControllerViewController ()

@end

@implementation MainHomeControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.leftDrawerViewController = [[UIViewController alloc] init];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    self.centerViewController = [sb instantiateViewControllerWithIdentifier:@"GroupTable"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
