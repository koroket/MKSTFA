//
//  FriendTableViewController
//  CandyStore
//
//  Created by sloot on 9/16/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "FriendTableViewController.h"
#import "GroupTableViewController.h"
#import "NetworkCommunication.h"
#import "MBProgressHUD.h"
#import "Group.h"

#import <FacebookSDK/FacebookSDK.h>

@interface FriendTableViewController ()

@property(nonatomic, strong) NSMutableArray *myFriends;
@property(nonatomic, strong) NSMutableArray *friendIds;
@property(nonatomic, strong) NSMutableArray *selectedFriends;

- (IBAction)buttonAddGroup:(id)sender;
- (IBAction)unwind:(id)sender;

@end

@implementation FriendTableViewController {
    
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFromFacebook];
    //[[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],NSForegroundColorAttributeName, [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], NSForegroundColorAttributeName, [UIFont fontWithName:@"Avenir" size:21], NSFontAttributeName, nil]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.selectedFriends addObject:[NetworkCommunication sharedManager].stringFBUserId];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Friends";
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.myFriends[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma message "You should consider checking against the list of friendIDs to see if this row is already selected. Checking against the acessoryType of a cell isn't a very elegant solution"
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.friendIds objectAtIndex:indexPath.row]];
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:[self.friendIds objectAtIndex:indexPath.row]];
    }
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"These are the selected friends %@", self.selectedFriends);
    }
}

#pragma mark - FaceBook Server Communication
/**
 * --------------------------------------------------------------------------
 * FaceBook
 * --------------------------------------------------------------------------
 */

- (void)loadFromFacebook {
    self.myFriends = [NSMutableArray array];
    self.friendIds = [NSMutableArray array];
    self.selectedFriends = [NSMutableArray array];
    [FBRequestConnection startWithGraphPath:@"/me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         NSDictionary *resultDictionary = (NSDictionary *)result;
         NSArray *data = [resultDictionary objectForKey:@"data"];
         for (NSDictionary *dic in data) {
             [self.myFriends addObject:[dic objectForKey:@"name"]];
             [self.friendIds addObject:[dic objectForKey:@"id"]];
         }
         dispatch_async(dispatch_get_main_queue(), ^(void) {
             [self.tableView reloadData];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         });
    }];
}

#pragma mark - Heroku Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

- (void)createGroup {
    [NetworkCommunication sharedManager].intYelpNumberOfLocations = 20;
    NSString *fixedURL = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/yelp/%@/%@/%@/%d/%@",
                          [NetworkCommunication sharedManager].stringCurrentLatitude,
                          [NetworkCommunication sharedManager].stringCurrentLongitude,
                          [NetworkCommunication sharedManager].stringYelpSearchTerm,
                          [NetworkCommunication sharedManager].intYelpNumberOfLocations,
                          [NetworkCommunication sharedManager].stringFBUserId];
    NSURL *url = [NSURL URLWithString:fixedURL];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:self.selectedFriends forKey:@"friends"];
    [dictionary setValue:[NetworkCommunication sharedManager].stringFBUserName forKey:@"myName"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             NSInteger responseStatusCode = [httpResponse statusCode];
             if (responseStatusCode == 200 && data) {
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     NSLog(@"start unwind");
                     [self performSegueWithIdentifier:@"Unwind" sender:self];
                 });
             } else {
                 NSLog(@"Sending to individuals failed");
             }
         }];
        [uploadTask resume];
        NSLog(@"Connected to server");
    } else {
        NSLog(@"Cannot connect to server");
    }
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */
- (IBAction)buttonAddGroup:(id)sender {
    [NetworkCommunication sharedManager].stringYelpSearchTerm = @"Restaurants";
    [NetworkCommunication sharedManager].stringCurrentLatitude = @"37.763264";
    [NetworkCommunication sharedManager].stringCurrentLongitude = @"-122.401379";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [self createGroup];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Details"]) {
        
    } else if ([segue.identifier isEqualToString:@"Unwind"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (IBAction)unwindToGroupViewController:(UIStoryboardSegue *)segue {
    
}

@end