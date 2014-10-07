//
//  FriendTableViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FriendTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Group.h"
#import "ListOfFriendsTableViewController.h"
#import <Foundation/Foundation.h>
#import "SwipeViewController.h"

@interface FriendTableViewController ()
- (IBAction)reloadData:(id)sender;



@end

@implementation FriendTableViewController

#pragma mark - init
// ----------------------------------------------------------------------
// **************************** Initialize ******************************
// ----------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myGroups = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRequests];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source
// ----------------------------------------------------------------------
// ****************************** Table *********************************
// ----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.myGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.myGroups objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Server communication
// ----------------------------------------------------------------------
// ****************************** Server *********************************
// ----------------------------------------------------------------------

-(void)getRequests {
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups", [[NSUserDefaults standardUserDefaults] stringForKey:@"myId"]];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Session Config
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    //Data Task Block
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        //HTTP Response
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //Status Code
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        //if success check
        if (responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.myGroups = [NSMutableArray array];
                for(int i = 0;i<fetchedData.count;i++)
                {
                    NSDictionary *data1  = [fetchedData objectAtIndex:i];
                    [self.myGroups addObject:data1[@"groupID"]];
                }
                
                [self.tableView reloadData];
            });
            
            // do something with this data
            // if you want to update UI, do it on main queue
        } else {
            // error handling
            NSLog(@"gucci");
        }
    }];
    [dataTask resume];
}

- (IBAction)reloadData:(id)sender {
    [self getRequests];
}

#pragma mark - navigation
// ----------------------------------------------------------------------
// **************************** Navigation ******************************
// ----------------------------------------------------------------------

- (IBAction)unwindToFriendTableViewController:(UIStoryboardSegue*)unwindSegue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddGroup"]) {
        ListOfFriendsTableViewController *controller = [segue destinationViewController];
        controller.parent = self;
        
    }else if ([segue.identifier isEqualToString:@"Swipe"]) {
        SwipeViewController *controller = [segue destinationViewController];
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        controller.groupID = [self.myGroups objectAtIndex:selectedIndexPath.row];
        
    }
}

@end
