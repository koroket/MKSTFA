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
@property(nonatomic, strong) NSMutableArray *myTokens;
@property(nonatomic, strong) NSMutableArray *selectedFriends;
@property(nonatomic, strong) NSMutableDictionary *dictionary;

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

/**
 *  Collects the device tokens
 */
-(void)collectTokens
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {
    NSLog(@"Friend Table - collectTokens - Start");
    }

    for(int i = 0; i < self.selectedFriends.count; i++)
    {
        [self getTokens:self.selectedFriends[i]];
    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {
    NSLog(@"Friend Table - CollectTokens - Finished");
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
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - commitEditingStyle - Start");}
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - commitEditingStyle - Finished");}
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

#pragma mark - Heroku Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

/**
 *  Get the Device tokens from the Users
 *
 *  @param userid - The User ID that gets passed
 */
-(void)getTokens:(NSString*)userid
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - getTokens - Start");}
    
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/%@token",
                          userid];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request
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
                    NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:nil];
                    NSDictionary *tempDictionary = fetchedData[0];
                    [self.myTokens addObject:tempDictionary[@"token"]];
                    [self sendNotification:tempDictionary[@"token"]];
                    if (self.myTokens.count == self.selectedFriends.count)
                    {
                        [self getYelp];
                    }
                });
             // do something with this data
             // if you want to update UI, do it on main queue
         }
         else
         {
             // error handling
             NSLog(@"ERROR GET TOKENS");
         }
         
         dispatch_async(dispatch_get_main_queue(), ^
            {
                
            });
     }];
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - getTokens - Finished");}
}

/**
 *  Gets called when the actual push notifications are ready to be sent, and sends them.
 *
 *  @param temptoken - The unique individual device token that the server then
 *                    sends the push notifcation to
 */
- (void)sendNotification:(NSString*)tempToken
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - sendNotification - Start");}

    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/push/%@/%@",
                          tempToken,
                          [self stringfix:[NetworkCommunication sharedManager].stringFBUserName]];

    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request
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
                    
                });
             // do something with this data
             // if you want to update UI, do it on main queue
         }
         else
         {
             // error handling
             NSLog(@"ERROR SEND NOTIFICATION");
         }
         dispatch_async(dispatch_get_main_queue(), ^
            {
                
            });
     }];
    [dataTask resume];

    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - sendNotification - Finished");}
}

-(NSString*)stringfix:(NSString*) str
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - stringfix - Start");}

    NSString* temp = [str stringByReplacingOccurrencesOfString:@" "
                                                    withString:@"_"];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - stringfix - Finished");}
    return temp;
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

    self.dictionary = [NSMutableDictionary dictionary];
    self.myFriends = [NSMutableArray array];
    self.friendIds = [NSMutableArray array];
    self.selectedFriends = [NSMutableArray array];
    self.myTokens = [NSMutableArray array];
    
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
             
             
         }
         
         dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }); //main queue dispatch
     }];//FBrequest block
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - loadFromFacebook - Finished");}

}

/**
 *  After a group is created, send push notifications to other members of group
 *
 *  @param code - This is the unique identifier for the group
 */
- (void)sendNewGroupsWithGroupCode:(NSString *)code
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - sendNewGroupsWithGroupCode - Start");}

    for (int i = 0; i < self.selectedFriends.count; i++)
    {
        //URL
        NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups",
                              [self.selectedFriends objectAtIndex:i]];
        NSURL *url = [NSURL URLWithString:fixedUrl];
        //Session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        //Request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"POST";
        //Dictionary
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    code, @"groupID",
                                    @(self.selectedFriends.count), @"number",
                                    @(0), @"currentIndex",
                                    [NetworkCommunication sharedManager].stringFBUserName, @"owner",
                                    [NetworkCommunication sharedManager].stringFBUserId, @"ownerID",
                                    nil];
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
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - sendNewGroupsWithGroupCode - Finished");}
}

/**
 *  Creates the actual group itself
 */
#pragma message "Also this method should probably not be part of this ViewController and instead should be moved into a backend access class"
- (void)createNewGroup
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - createNewGroup - Start");}

    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups"];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    //Session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    //Data Task Block
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.dictionary
                                                   options:kNilOptions
                                                     error:&error];
    if (!error)
    {
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
                        NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:nil];
                        NSDictionary *data1 = [fetchedData objectAtIndex:0];
                        NSString *code = data1[@"_id"];
                        [self sendNewGroupsWithGroupCode:code];
                    });//Dispatch main queue block
             }//if
             else
             {
                 NSLog(@"Group creation failed");
             }
         }];//Upload task Block
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else
    {
        NSLog(@"Cannot connect to server");
    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - createNewGroup - Finished");}
}

#pragma mark - Yelp Server Communication
/**
 * --------------------------------------------------------------------------
 * Yelp
 * --------------------------------------------------------------------------
 */

- (void)getYelp
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - getYelp - Start");}

    
    if (self.selectedFriends.count > 1)
    {
        //URL
        NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%@/%@/%d",
                              [NetworkCommunication sharedManager].stringCurrentLatitude,
                              [NetworkCommunication sharedManager].stringCurrentLongitude,
                              [NetworkCommunication sharedManager].stringYelpSearchTerm,
                              [NetworkCommunication sharedManager].intYelpNumberOfLocations
                              ];
        NSURL *url = [NSURL URLWithString:fixedURL];
        //Request
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:30.0];
        [request setHTTPMethod:@"GET"];
        //Session
        NSURLSession *urlSession = [NSURLSession sharedSession];
        //Data Task
        NSURLSessionDataTask *dataTask =
        [urlSession dataTaskWithRequest:request
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
#pragma message "This section needs more comments, ideally you should describe what is going on here on a conceptual level"
                        // Creates local data for yelp info
                        NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:0
                                                                                      error:nil];
                        NSArray *buisinesses = [NSArray array];
                        buisinesses = fetchedData[@"businesses"];
                        // Creates array of empty replies
                        NSMutableArray *tempReplies = [NSMutableArray array];
                        for (int i = 0; i < buisinesses.count; i++)
                        {
                            [tempReplies addObject:[NSNumber numberWithInt:0]];
                        }
                        // Creates Decision Objects
                        NSMutableArray *decisionObjects = [NSMutableArray array];
                        // insert object info here
                        for (int i = 0; i < buisinesses.count; i++)
                        {
                            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                            NSDictionary *dictionary = [buisinesses objectAtIndex:i];
                            [temp setObject:dictionary[@"name"] forKey:@"Name"];
                            if(dictionary[@"image_url"]!=nil)
                            {
                                [temp setObject:dictionary[@"image_url"] forKey:@"ImageURL"];
                            }
                            [decisionObjects addObject:temp];
                        }
                        
                        //Dictionary Handling
                        //Device tokens
                        [self.dictionary setValue:self.myTokens forKey:@"Tokens"];
                        //Sets DONE
                        [self.dictionary setValue:@(-1) forKey:@"Done"];
                        //Sets the business count
                        [self.dictionary setValue:@(buisinesses.count) forKey:@"Number"];
                        //Sets the replies
                        [self.dictionary setValue:tempReplies forKey:@"Replies"];
                        //Sets the decision objects
                        [self.dictionary setValue:decisionObjects forKey:@"Objects"];
                        //Creates the group
                        [self createNewGroup];
                    });
                 //where to stick dispatch to main queue
             }
             else
             {
                 // error handling
                 NSLog(@"ERROR - Yelp Failed");
             }
         }];//Data Task Block
        [dataTask resume];
    }
    else
    {
        NSLog(@"ERROR - You didnt select any friends");

    }
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - getYelp - Finished");}
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

- (IBAction)unwindToSelfViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

- (IBAction)unwind:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - unwind - Start");}

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    NSLog(@"Friend Table - unwind - Loading");
    [self collectTokens];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"FriendTable - unwind - Finished");}
}

@end