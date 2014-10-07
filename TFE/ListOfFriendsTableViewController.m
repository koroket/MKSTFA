//
//  CandyTableListTableViewController.m
//  CandyStore
//
//  Created by sloot on 9/16/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "ListOfFriendsTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Group.h"
#import "FriendTableViewController.h"

@interface ListOfFriendsTableViewController()

@property (nonatomic,strong) NSMutableArray *myFriends;
@property (nonatomic,strong) NSMutableArray *friendIds;
@property (nonatomic,strong) NSMutableArray *selectedFriends;
@property (nonatomic,strong) NSMutableArray *placeNames;

@end

@implementation ListOfFriendsTableViewController{}

#pragma mark - init
// ----------------------------------------------------------------------
// **************************** Initialize ******************************
// ----------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFromFacebook];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
// ----------------------------------------------------------------------
// ****************************** Table *********************************
// ----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [self.myFriends count];
}

//cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.myFriends[indexPath.row];
    return cell;
}

//commit editing style for row at index path
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.candies removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//did select row at index path
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.friendIds objectAtIndex:indexPath.row]];
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:[self.friendIds objectAtIndex:indexPath.row]];
    }
    NSLog(@"These are the selected friends %@", self.selectedFriends);
}

#pragma mark - Heroku Server communication
// ----------------------------------------------------------------------
// ****************************** Server *********************************
// ----------------------------------------------------------------------

-(void)sendNewGroupsWithGroupCode:(NSString *)code {
    for(int i = 0; i<self.selectedFriends.count; i++) {
        //URL
        NSString *fixedUrl = [NSString stringWithFormat: @"http://young-sierra-7245.herokuapp.com/ppl/%@groups", [self.selectedFriends objectAtIndex:i]];
        NSURL *url = [NSURL URLWithString:fixedUrl];
        
        //Config
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        //Request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"POST";
        
        //Dictionary
        //code, groupID, nil
        NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys: code, @"groupID", nil];
        
        //Error handling
        NSError *error = nil;
        //NSData conversion
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
        
        if (!error) {
            // Upload Task
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data
                                                              completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
            {
                
            }];
            // 5
            [uploadTask resume];
            NSLog(@"Connected to server");
        } else {
            NSLog(@"Cannot connect to server");
        }
    }
}

-(void)createNewGroup {
    
    [self.selectedFriends addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"myId"]];
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups"];
    // 1
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    
    
    // 3
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"no",
                                       @"done",
                                       self.placeNames,
                                       @"locations",
                                       nil];
    for (int i = 0;i<self.selectedFriends.count;i++) {
        NSArray *replies = [NSArray array];
        [dictionary setValue:replies forKey:[self.selectedFriends objectAtIndex:i]];
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    
    if (!error) {
        // 4
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       
                                                                       
                                                                       NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                                       
                                                                       NSInteger responseStatusCode = [httpResponse statusCode];
                                                                       
                                                                       if (responseStatusCode == 200 && data) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                               NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                               
                                                                               NSDictionary *data1  = [fetchedData objectAtIndex:0];
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               NSString* code = data1[@"_id"];
                                                                               
                                                                               [self sendNewGroupsWithGroupCode:code];
                                                                               
                                                                           });
                                                                       }
                                                                       
                                                                       
                                                                   }];
        
        // 5
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else {
        NSLog(@"Cannot connect to server");
    }
}

- (void)deleteGroup {
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/54311e17512a2302001bcc3f"];
    // 1
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
            });
            
            // do something with this data
            // if you want to update UI, do it on main queue
        } else {
            // error handling
            NSLog(@"cannot connect to server");
        }
    }];
    [dataTask resume];
    
}

#pragma mark - Facebook Server communication
// ----------------------------------------------------------------------
// ****************************** Server *********************************
// ----------------------------------------------------------------------

- (void)loadFromFacebook {
    self.myFriends = [NSMutableArray array];
    self.friendIds = [NSMutableArray array];
    self.selectedFriends = [NSMutableArray array];
    self.placeNames = [NSMutableArray array];
    
    [FBRequestConnection startWithGraphPath:@"/me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        
        NSDictionary *resultDictionary = (NSDictionary*)result;
        
        NSArray *data = [resultDictionary objectForKey:@"data"];
        
        for(NSDictionary *dic in data) {
            [self.myFriends addObject:[dic objectForKey:@"name"]];
            [self.friendIds addObject:[dic objectForKey:@"id"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });//reload data block
    }];
}

#pragma mark - Yelp Server communication
// ----------------------------------------------------------------------
// ****************************** Server *********************************
// ----------------------------------------------------------------------
- (void)getYelp {
    if(self.selectedFriends.count>0)
    {
        NSString* fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/yeah",[[NSUserDefaults standardUserDefaults] stringForKey:@"location"]];
        NSURL *url = [NSURL URLWithString:fixedURL];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [request setHTTPMethod:@"GET"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger responseStatusCode = [httpResponse statusCode];
            
            if (responseStatusCode == 200 && data) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    NSArray *buisinesses = [NSArray array];
                    buisinesses =  fetchedData[@"businesses"];
                    for(int i = 0; i<20;i++)
                    {
                        NSDictionary* temp = [buisinesses objectAtIndex:i];
                        [self.placeNames addObject:temp[@"name"]];
                    }
                    
                    [self createNewGroup];
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
}


#pragma mark - navigation
// ----------------------------------------------------------------------
// **************************** Navigation ******************************
// ----------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Details"]) {
        
    } else if ([segue.identifier isEqualToString:@"unwindToFriend"]) {
        
        [self getYelp];
    }
}


- (IBAction)unwindToSelfViewController:(UIStoryboardSegue*)unwindSegue {
    
}
@end
