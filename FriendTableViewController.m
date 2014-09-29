//
//  FriendTableViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FriendTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendTableViewController ()

@property  (nonatomic, strong) NSMutableArray* myFriends;
@property (nonatomic,strong) NSMutableArray* friendIds;
@end

@implementation FriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myFriends = [NSMutableArray array];
     self.friendIds = [NSMutableArray array];
    
    [FBRequestConnection startWithGraphPath:@"/me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
    
        NSDictionary *resultDictionary = (NSDictionary*)result;
        
        NSArray *data = [resultDictionary objectForKey:@"data"];
        
        for(NSDictionary *dic in data)
        {
            [self.myFriends addObject:[dic objectForKey:@"name"]];
            [self.friendIds addObject:[dic objectForKey:@"id"]];
        }
//        FBGraphObject* sd ;
//        [sd ]
//        NSMutableArray *yeah = [NSMutableArray array];
//        [yeah addObject:things];
//        NSLog(@"ALL == %@",result);
//        NSLog(@"ALL == %@",things);
        
        //[self.myFriends addObject:[result getObjects:<#(__unsafe_unretained id *)#> andKeys:<#(__unsafe_unretained id *)#>]];
        
        
        
        
    }];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    cell.textLabel.text = @"hhh";
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
