//
//  FriendTableViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "GroupTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Group.h"
#import "FriendTableViewController.h"
#import <Foundation/Foundation.h>
#import "DraggableBackground.h"
#import "MBProgressHUD.h"
#import "NetworkCommunication.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "AMSmoothAlertView.h"
#import "TDBadgedCell.h"
@interface GroupTableViewController ()

- (IBAction)reloadData:(id)sender;
@property (nonatomic,strong) NSMutableArray* myOwners;
@property (nonatomic,strong) NSMutableArray* myOwnerIds;

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

    self.myGroups = [NSMutableArray array];
    self.numOfPeople = [NSMutableArray array];
    self.myOwners = [NSMutableArray array];
    self.myOwnerIds = [NSMutableArray array];
    
    [self.tableView addPullToRefreshWithActionHandler:^
    {
        [self getRequests];
    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getRequests];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    myIndex = indexPath.row;
    
    //Set the singleton string equal to selected group ID
    [NetworkCommunication sharedManager].stringSelectedGroupID = [self.myGroups objectAtIndex:indexPath.row];
    //and the number of users in the selected group
    [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople =[(NSNumber*)self.numOfPeople[indexPath.row] intValue];
    
    // URL
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
              
              //Set this array equal to the Device tokens from all of the users in the selected group
              [NetworkCommunication sharedManager].arraySelectedGroupDeviceTokens = fetchedData[@"Tokens"];
              

              [self performSegueWithIdentifier:@"Swipe" sender:self];
              
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.myGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //Facebook connection used for profile picture
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,
                                                           NSDictionary<FBGraphUser> *FBuser,
                                                           NSError *error)
     {
         if (error)
         {
             // Handle error
         }
         
         else
         {
             //NSString *userName = [FBuser name];
             
             //NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser objectID]];
             
             NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [self.myOwnerIds objectAtIndex:self.myOwners.count-1-indexPath.row]];
             
             cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
            
             
         }
     }];
    
    //Code to display badge that appears next to the group
    cell.textLabel.text = [NSString stringWithFormat:@"%@'s Group Event",[self.myOwners objectAtIndex:self.myOwners.count-1-indexPath.row]];
    cell.badgeString = @"6";
    cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    cell.badge.fontSize = 18;
    
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NetworkCommunication *sharedCommunication = [NetworkCommunication alloc];
    [sharedCommunication serverRequests: [NSString stringWithFormat:@"ppl/%@groups", [NetworkCommunication sharedManager].stringFBUserId]
                                   type:@"GET"
                         whatDictionary:nil
                              withBlock:^(void)
     {
         
         NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:sharedCommunication.myData options:0 error:nil];
         self.myGroups = [NSMutableArray array];
         
         for (int i = 0; i < fetchedData.count; i++)
         {
             NSDictionary *data1 = [fetchedData objectAtIndex:i];
             [self.myGroups addObject:data1[@"groupID"]];
             
             [self.numOfPeople addObject:data1[@"number"]];
             [self.myOwners addObject:data1[@"owner"]];
             [self.myOwnerIds addObject:data1[@"ownerID"]];
         }
         
         [self.tableView reloadData];
         [self.tableView.pullToRefreshView stopAnimating];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Gucci" andText:@"yeah" andCancelButton:YES forAlertType:AlertSuccess];
         [alert show];
     }];
    
}

- (IBAction)reloadData:(id)sender
{
    [self resetEverything];
    //[self yesWith:3 andUrl:@"543482c59b6f750200271e81"];
}

- (void)yesWith:(int)index andUrl:(NSString *)tempUrl
{
    NSString *fixedUrl =
        [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@/%d", tempUrl, index];
    // 1
    NSURL *url = [NSURL URLWithString:fixedUrl];
    // 1

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"PUT"];

    NSURLSession *urlSession = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask =
        [urlSession dataTaskWithRequest:request
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {

      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger responseStatusCode = [httpResponse statusCode];

      if (responseStatusCode == 200 && data)
      {
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              NSDictionary *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSNumber *a = fetchedData[@"agree"];
              int t = [a intValue];
              if (t == 3)
              {
                  [self performSegueWithIdentifier:@"Done" sender:self];
              }
          });

          // do something with this data
          // if you want to update UI, do it on main queue
      }
      else
      {
          // error handling
      }
    }];
    [dataTask resume];
}

- (void)deleteGroup:(NSString *)pplid with:(NSString *)myId
{
    //URL
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
}

- (void)deleteIndividualGroup:(NSString *)str
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@", str];
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
    }];//Data Task Block
    [dataTask resume];
}

- (void)resetGroups
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups"];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
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
          NSLog(@"gucci");
      }
  }]; //Data Task Block
    
    [dataTask resume];
}

- (void)resetPeople:(NSString *)pplid
{
    //URL
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
          NSLog(@"gucci");
      }
    }];
    [dataTask resume];
}

- (void)resetEverything
{
    [self resetGroups];
    [self resetPeople:@"10204805165711346"];
    [self resetPeople:@"10153248739313289"];
    [self resetPeople:@"10202657658737811"];
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
    if ([segue.identifier isEqualToString:@"AddGroup"])
    {
        FriendTableViewController *controller = [segue destinationViewController];
        controller.parent = self;
    }
    else if ([segue.identifier isEqualToString:@"Swipe"])
    {
        DraggableBackground *controller = [segue destinationViewController];
        
        controller.groupID = [self.myGroups objectAtIndex:self.myGroups.count-1-myIndex];
        controller.numOfPeople = (int)[self.numOfPeople objectAtIndex:self.myGroups.count-1-myIndex];
    }
}

@end
