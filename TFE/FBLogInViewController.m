//
//  FBLogInViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FBLogInViewController.h"

@interface FBLogInViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation FBLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView.readPermissions = @[@"public_profile",@"email",@"user_friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSString* userid = user.name;
    //NSLog(userid);
    
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TableView"];
    [[self navigationController] pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
    
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
