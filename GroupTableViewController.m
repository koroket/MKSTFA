//
//  FriendTableViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "GroupTableViewController.h"
#import "Group.h"
#import "FriendTableViewController.h"
#import "DraggableBackground.h"
#import "MBProgressHUD.h"
#import "NetworkCommunication.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "TDBadgedCell.h"

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface GroupTableViewController ()

@property (nonatomic,strong) NSMutableArray* myOwners;
@property (nonatomic,strong) NSMutableArray* myOwnerIds;
@property (nonatomic,strong) NSMutableArray* myDBIds;
@property (nonatomic,strong) NSMutableArray* myGroupIndex;
@property (nonatomic,strong) NSMutableArray* myImages;

- (IBAction)reloadData:(id)sender;

@end


@implementation GroupTableViewController
{
    int myIndex;
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
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidLoad - Start");}
    
    [self.tableView addPullToRefreshWithActionHandler:^
    {
        [self getRequests];
    }];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidLoad - Finished");}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewWillAppear - Start");}
    
    self.myGroups = [NSMutableArray array];
    self.numberOfPeople = [NSMutableArray array];
    self.myOwners = [NSMutableArray array];
    self.myOwnerIds = [NSMutableArray array];
    self.myDBIds = [NSMutableArray array];
    self.myGroupIndex = [NSMutableArray array];
    self.view.userInteractionEnabled = false;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getRequests];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewWillAppear - Finished");}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidAppear- Start");}
    
    [self.tableView reloadData];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidAppear - Finished");}
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - didSelectRowAtIndexPath - Start");}

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    myIndex = indexPath.row;
    
    //Set the singleton string equal to selected group ID
    [NetworkCommunication sharedManager].stringSelectedGroupID = [self.myGroups objectAtIndex:indexPath.row];
    //and the number of users in the selected group
    [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople =[(NSNumber*)self.numberOfPeople[indexPath.row] intValue];
    [NetworkCommunication sharedManager].stringCurrentDB = self.myDBIds[indexPath.row];
    [NetworkCommunication sharedManager].intSelectedGroupProgressIndex = [(NSNumber*)self.myGroupIndex[indexPath.row] intValue];
    
    // URL
    #pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@",
                                                    [self.myGroups objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    // Request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    // Request type
    [request setHTTPMethod:@"GET"];
    // Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    // Data Task Block
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
              NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:nil];
              //Set the singleton array equal to all of the fetched card data from Yelp
              [NetworkCommunication sharedManager].arraySelectedGroupCardData = fetchedData[@"Objects"];
              NSMutableArray* tempArray = [NSMutableArray array];
              for(int i = [NetworkCommunication sharedManager].intSelectedGroupProgressIndex;i<[NetworkCommunication sharedManager].arraySelectedGroupCardData.count;i++)
              {
                  [tempArray addObject:[NetworkCommunication sharedManager].arraySelectedGroupCardData[i]];
              }
              [NetworkCommunication sharedManager].arraySelectedGroupCardData = tempArray;

              //Set this array equal to the Device tokens from all of the users in the selected group
              [NetworkCommunication sharedManager].arraySelectedGroupDeviceTokens = fetchedData[@"Tokens"];
              

              [self performSegueWithIdentifier:@"Swipe" sender:self];
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
          }); // Main Queue dispatch block

          // do something with this data
          // if you want to update UI, do it on main queue
        }
        else
        {
          // error handling
        }
        }]; // Data Task Block
    [dataTask resume];

    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - didSelectRowAtIndexPath - Finished");}
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - numberOfRowsInSection - Start");}
    
    if(self.myImages.count==0)
    {
        if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - numberOfRowsInSection - Finished");}
        return 0;
    }
    else
    {
        if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - numberOfRowsInSection - Finished");}
        return self.myGroups.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - cellForRowAtIndexPath - Start");}

    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //Facebook connection used for profile picture
    cell.imageView.image = self.myImages[indexPath.row];
    
    //Code to display badge that appears next to the group
    cell.textLabel.text = [NSString stringWithFormat:@"%@'s Group Event",[self.myOwners objectAtIndex:indexPath.row]];
    cell.badgeString = [NSString stringWithFormat:@"%@",[self.myGroupIndex objectAtIndex:indexPath.row]];
    cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    cell.badge.fontSize = 18;
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - cellForRowAtIndexPath - Finished");}
    return cell;
}

#pragma mark - Heroku
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

- (void)getRequests
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - getRequests - Start");}
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NetworkCommunication *sharedCommunication = [NetworkCommunication alloc];
    [sharedCommunication serverRequests: [NSString stringWithFormat:@"ppl/%@groups", [NetworkCommunication sharedManager].stringFBUserId]
                                   type:@"GET"
                         whatDictionary:nil
                              withBlock:^(void)
     {
         self.myGroups = [NSMutableArray array];
         self.numberOfPeople = [NSMutableArray array];
         self.myOwners = [NSMutableArray array];
         self.myOwnerIds = [NSMutableArray array];
         self.myDBIds = [NSMutableArray array];
         self.myGroupIndex = [NSMutableArray array];
         self.myImages = [NSMutableArray array];
         
         NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:sharedCommunication.myData
                                                                options:0
                                                                  error:nil];
         self.myGroups = [NSMutableArray array];
         
         for (int i = 0; i < fetchedData.count; i++)
         {
             NSDictionary *data1 = [fetchedData objectAtIndex:i];
             [self.myGroups addObject:data1[@"groupID"]];
             
             [self.numberOfPeople addObject:data1[@"number"]];
             [self.myOwners addObject:data1[@"owner"]];
             [self.myOwnerIds addObject:data1[@"ownerID"]];
             [self.myDBIds addObject:data1[@"_id"]];
             [self.myGroupIndex addObject:data1[@"currentIndex"]];
         }
         [self downloadImages];
     }];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - getRequests - Finished");}
}

#pragma message "bad method name because it is very similar to UITableView's reloadData method"
- (IBAction)reloadData:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - reloadData - Start");}
    
    //[self getGoogle];
    [self resetEverything];
    //[self yesWith:3 andUrl:@"543482c59b6f750200271e81"];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - reloadData - Finshed");}
}

#pragma message "message name does not contain enough information. Pretty sure you are not downloading google ;)"

- (void)deleteGroup:(NSString *)pplid
               with:(NSString *)myId
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - deleteGroup - Start");}
    
    //URL
    #pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl =
        [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups/%@", pplid, myId];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
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
          NSLog(@"cannot connect to server");
        }
    }];
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - deleteGroup - Finished");}
}

- (void)deleteIndividualGroup:(NSString *)str
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - deleteIndividualGroup - Start");}
    
    //URL
    #pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@", str];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
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
          NSLog(@"cannot connect to server");
      }
    }];//Data Task Block
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - deleteIndividualGroup - Finished");}
}

- (void)resetGroups
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - resetGroups - Start");}

    //URL
    #pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups"];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
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
              NSArray *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:nil];
              self.myGroups = [NSMutableArray array];
              
              for (int i = 0; i < fetchedData.count; i++)
              {
                  NSDictionary *data1 = [fetchedData objectAtIndex:i];
                  [self deleteIndividualGroup:data1[@"_id"]];
              }
              [self.tableView reloadData];
          });
          // do something with this data
          // if you want to update UI, do it on main queue
      }
      else
      {
          // error handling
          NSLog(@"ERROR: GroupTable - resetGroups");
      }
    }]; //Data Task Block
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - resetGroups - Finished");}
}

- (void)resetPeople:(NSString *)pplid
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - resetPeople - Start");}
    
    //URL
    #pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups", pplid];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
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
              NSArray *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:nil];

              for (int i = 0; i < fetchedData.count; i++)
              {
                  NSDictionary *data1 = [fetchedData objectAtIndex:i];
                  [self deleteGroup:pplid with:data1[@"_id"]];
              }

              [self.tableView reloadData];
          });//dispatch main queue block 

          // do something with this data
          // if you want to update UI, do it on main queue
      }
      else
      {
          // error handling
          NSLog(@"ERROR RESET PEOPLE");
      }
    }];
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - resetPeople - Finished");}
}

#pragma message "Is this method only used for testing purposes? If so, please add a comment"
- (void)resetEverything
{
    //for debug only
    [self resetGroups];
    [self resetPeople:@"10204805165711346"];
    [self resetPeople:@"10153248739313289"];
    [self resetPeople:@"10202657658737811"];
}

#pragma mark - Google
/**
 * --------------------------------------------------------------------------
 * Google
 * --------------------------------------------------------------------------
 */

- (void)getGoogle
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - getGoogle - Start");}
    
    //URL
    NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/google/food"];
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
                    // Creates local data for yelp info
                    NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:0
                                                                                  error:nil];
                    NSLog(@"%@",fetchedData);
                    NSArray *myArray = [NSArray array];
                    myArray = fetchedData;
                    NSDictionary *place1 = myArray[0];
                    NSArray* photos = place1[@"photos"];
                    NSLog(@"%@",photos);
                });
             //where to stick dispatch to main queue
         }
         else
         {
             // error handling
             NSLog(@"ERROR: GroupTable - getGoogle");
         }
     }];//Data Task Block
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - getGoogle - Finished");}
}

#pragma mark - Facebook
/**
 * --------------------------------------------------------------------------
 * Facebook
 * --------------------------------------------------------------------------
 */

-(void)downloadImages
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - downloadImages - Start");}
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,
                                                           NSDictionary<FBGraphUser> *FBuser,
                                                           NSError *error)
     {
         if (error)
         {
             // Handle error
             NSLog(@"Error: download Images");
         }
         else
         {
             //NSString *userName = [FBuser name];
             //NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser objectID]];
             for(int i = 0;i<self.myOwnerIds.count;i++)
             {
                 NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [self.myOwnerIds objectAtIndex:i]];
                 UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                 [self.myImages addObject:tempImage];
             }
             [self.tableView reloadData];
             [self.tableView.pullToRefreshView stopAnimating];
             self.view.userInteractionEnabled = true;
             [self.navigationController setNavigationBarHidden:NO animated:YES];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
     }];
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - downloadImages - Finished");}
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

- (IBAction)unwindToFriendTableViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - prepareForSegue - Start");}
    
    if ([segue.identifier isEqualToString:@"AddGroup"])
    {
        FriendTableViewController *controller = [segue destinationViewController];
        controller.parent = self;
    }
    else if ([segue.identifier isEqualToString:@"Swipe"])
    {
        DraggableBackground *controller = [segue destinationViewController];
        #pragma message "You should add a comment to explain why you calculate the index like this 'self.myGroups.count-1-myIndex'"
        controller.groupID = [self.myGroups objectAtIndex:myIndex];

    }
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - prepareForSegue - Finished");}
}

@end
