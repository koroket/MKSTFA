//
//  CandyTableListTableViewController.m
//  CandyStore
//
//  Created by sloot on 9/16/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "FriendTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Group.h"
#import "GroupTableViewController.h"
#import "MBProgressHUD.h"
#import "NetworkCommunication.h"

@interface FriendTableViewController ()

@property(nonatomic, strong) NSMutableArray *myFriends;
@property(nonatomic, strong) NSMutableArray *friendIds;
@property(nonatomic, strong) NSMutableArray *selectedFriends;
@property(nonatomic, strong) NSMutableDictionary *dictionary;
@property(nonatomic,strong) NSMutableArray *myTokens;

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
  [self loadFromFacebook];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    
    
    [self.selectedFriends addObject:[NetworkCommunication sharedManager].stringFBUserId];
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
	return [self.myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	cell.textLabel.text = self.myFriends[indexPath.row];


	return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	NSLog(@"These are the selected friends %@", self.selectedFriends);
}

#pragma mark - Heroku Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

-(void)getTokens:(NSString*)userid
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/%@token",
                          userid];
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
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:nil];
                
                NSDictionary *tempDictionary = fetchedData[fetchedData.count - 1];
                
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
            NSLog(@"gucci");
        }
        
    dispatch_async(dispatch_get_main_queue(), ^
    {
        
    });
                  }];
    [dataTask resume];
}

/**
 *  Gets called when the actual push notifications are ready to be sent, and sends them.
 *
 *  @param temptoken - The unique individual device token that the server then
 *                     sends the push notifcation to
 */
- (void)sendNotification:(NSString*)tempToken
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/push/%@/%@",
                          tempToken,
                          [self stringfix:[NetworkCommunication sharedManager].stringFBUserName]];
    
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
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
            NSLog(@"gucci");
        }
        dispatch_async(dispatch_get_main_queue(), ^
        {
            
        });
    }];
    [dataTask resume];
}
-(NSString*)stringfix:(NSString*) str
{
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return temp;
}

#pragma mark - FaceBook Server Communication
/**
 * --------------------------------------------------------------------------
 * FaceBook
 * --------------------------------------------------------------------------
 */

- (void)loadFromFacebook
{
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
             

         }//for
         
         dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self.tableView reloadData];
                
            }); //main queue dispatch
         
     }];//FBrequest block
    
}//load

/**
 *  After a group is created, send push notifications to other members of group
 *
 *  @param code - This is the unique identifier for the group
 */
- (void)sendNewGroupsWithGroupCode:(NSString *)code
{

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
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];

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
            
        }];//upload task Block

      // 5
      [uploadTask resume];
      NSLog(@"Connected to server");
    }
    else
    {
      NSLog(@"Cannot connect to server");
    }
  }
}

- (void)createNewGroup
{
  NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups"];
  // 1
  NSURL *url = [NSURL URLWithString:fixedUrl];
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

  // 2
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";

  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:self.dictionary
                                                 options:kNilOptions
                                                   error:&error];
  if (!error)
  {
    // 4
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
     }];//Upload task Block
    [uploadTask resume];
    NSLog(@"Connected to server");
  }
  else
  {
    NSLog(@"Cannot connect to server");
  }
}

#pragma mark - Yelp Server Communication
/**
 * --------------------------------------------------------------------------
 * Yelp
 * --------------------------------------------------------------------------
 */
-(void)collectTokens
{
    for(int i = 0; i < self.selectedFriends.count; i++)
    {
        [self getTokens:self.selectedFriends[i]];
    }
}


- (void)getYelp
{

  if (self.selectedFriends.count > 1)
  {
      
      //URL
      NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%d/%@",
                            [NetworkCommunication sharedManager].stringYelpLocation,
                            [NetworkCommunication sharedManager].intYelpNumberOfLocations,
                            [NetworkCommunication sharedManager].stringYelpSearchTerm];
      NSURL *url = [NSURL URLWithString:fixedURL];
      
      //Request
      NSMutableURLRequest *request =
      [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
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
                   // Creates local data for yelp info
                   NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0 error:nil];
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

                   // 3
                   [self.dictionary setValue:self.myTokens
                                      forKey:@"Tokens"];
                   [self.dictionary setValue:@(-1)
                                      forKey:@"Done"];
                   [self.dictionary setValue:@(buisinesses.count)
                                      forKey:@"Number"];
                   [self.dictionary setValue:tempReplies
                                      forKey:@"Replies"];
                   [self.dictionary setValue:decisionObjects
                                      forKey:@"Objects"];

                   [self createNewGroup];
                  
              });//MainQueue Dispatch block

            // do something with this data
            // if you want to update UI, do it on main queue
           }
           else
           {
               // error handling
               NSLog(@"gucci");
           }
       }];//Data Task Block
      [dataTask resume];
  }
  else
  {
      NSLog(@"You didnt select any friends");
  }
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Details"])
    {
    }
    else if ([segue.identifier isEqualToString:@"Unwind"])
    {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (IBAction)unwindToSelfViewController:(UIStoryboardSegue *)unwindSegue
{
}

- (IBAction)unwind:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
     [self collectTokens];


}
@end
