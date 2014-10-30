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

- (IBAction)unwind:(id)sender;

@end

@implementation FriendTableViewController
{
    
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"FriendTable - viewDidLoad - Start");
    }
    [self loadFromFacebook];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"FriendTable - viewDidLoad - Finsihed");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"FriendTable - viewWillAppear - Start");
    }

    [self.tableView reloadData];
    
    [self.selectedFriends addObject:[NetworkCommunication sharedManager].stringFBUserId];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Friends";
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"FriendTable - viewWillAppear - Finished");
    }

}


#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - numberOfRowsInSection - Start");}

    // Return the number of rows in the section.
    return [self.myFriends count];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - numberOfRowsInSection - Finished");}
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - cellForRowAtIndexPath - Start");}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.myFriends[indexPath.row];
    return cell;
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - cellForRowAtIndexPath - Finished");}
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - didSelectRowAtIndexPath - Start");}
    
#pragma message "You should consider checking against the list of friendIDs to see if this row is already selected. Checking against the acessoryType of a cell isn't a very elegant solution"
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.friendIds objectAtIndex:indexPath.row]];
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:[self.friendIds objectAtIndex:indexPath.row]];
    }
    
    
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"These are the selected friends %@", self.selectedFriends);
        NSLog(@"FriendTable - didSelectRowAtIndexPath - Finished");
    }
}



#pragma mark - FaceBook Server Communication
/**
 * --------------------------------------------------------------------------
 * FaceBook
 * --------------------------------------------------------------------------
 */

/**
 *  Load any information necessary from facebook
 */
- (void)loadFromFacebook
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - loadFromFacebook - Start");}


    self.myFriends = [NSMutableArray array];
    self.friendIds = [NSMutableArray array];
    self.selectedFriends = [NSMutableArray array];

    
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         //dictionary
         NSDictionary *resultDictionary = (NSDictionary *)result;
         NSArray *data = [resultDictionary objectForKey:@"data"];
         
         for (NSDictionary *dic in data)
         {
             [self.myFriends addObject:[dic objectForKey:@"name"]];
             [self.friendIds addObject:[dic objectForKey:@"id"]];
             
             
         }//for
         
         dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            }); //main queue dispatch
         
     }];//FBrequest block
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - loadFromFacebook - Finished");}

}

#pragma mark - FaceBook Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */
- (void)createGroup
{




        //URL
        NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%@/%@/%d/%@",
                              [NetworkCommunication sharedManager].stringCurrentLatitude,
                              [NetworkCommunication sharedManager].stringCurrentLongitude,
                              [NetworkCommunication sharedManager].stringYelpSearchTerm,
                              [NetworkCommunication sharedManager].intYelpNumberOfLocations,
                              [NetworkCommunication sharedManager].stringFBUserId
                              ];
        NSURL *url = [NSURL URLWithString:fixedURL];

        //Session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        //Request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"POST";
        //Dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:self.selectedFriends forKey:@"friends"];
    [dictionary setValue:[NetworkCommunication sharedManager].stringFBUserName forKey:@"myName"];
    //errorHandlign
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:kNilOptions
                                                         error:&error];
        if (!error)
        {
            //Upload
            NSURLSessionUploadTask *uploadTask =
            [session uploadTaskWithRequest:request
                                  fromData:data
                         completionHandler:^(NSData *data,
                                             NSURLResponse *response,
                                             NSError *error)
             {
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                 NSInteger responseStatusCode = [httpResponse statusCode];
                 if (responseStatusCode == 200 && data)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                                        [self performSegueWithIdentifier:@"Unwind" sender:self];
                                    });//Dispatch main queue block
                 }//if
                 else
                 {
                     NSLog(@"Sending to individuals failed");
                 }
             }];//upload task Block
            [uploadTask resume];
            NSLog(@"Connected to server");
        }
        else
        {
            NSLog(@"Cannot connect to server");
        }
    

}


#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - prepareForSeque - Start");}

    if ([segue.identifier isEqualToString:@"Details"])
    {
        
    }
    else if ([segue.identifier isEqualToString:@"Unwind"])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - prepareForSeque - Finished");}
}
- (IBAction)unwind:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - unwind - Start");}

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    NSLog(@"Friend Table - unwind - Loading");
    [self createGroup];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - unwind - Finished");}
}

@end