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
- (IBAction)logOutPressed:(id)sender;

@end


@implementation GroupTableViewController
{
    int myIndex;
    int counter;
    bool isTableLoading;
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



    [NetworkCommunication sharedManager].controllerCurrentGroup = self;

    [self.navigationItem setHidesBackButton:NO animated:YES];

    [self.tableView addPullToRefreshWithActionHandler:^
    {
        [self tableWillReload];
    }];
}

-(void)tableWillReload
{
    //[super viewWillAppear:animated];
    
    self.myOwners = [NSMutableArray array];
    self.myOwnerIds = [NSMutableArray array];
    self.myDBIds = [NSMutableArray array];
    self.myGroupIndex = [NSMutableArray array];
    self.view.userInteractionEnabled = false;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self getRequests];
    
    if(!isTableLoading)
    {
//#pragma message "use YES/NO instead ot true/false"
        isTableLoading = true;
        self.view.userInteractionEnabled = false;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading Groups";
        [[NetworkCommunication sharedManager] getRequests];
    }
}

-(void)tableDidReload
{
    //[super viewDidAppear:animated];
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidAppear- Start");}
    
    [self.tableView reloadData];
//#pragma message "duplicate reloadData call?"
    [self.tableView reloadData];
    self.view.userInteractionEnabled = true;
    [self.tableView.pullToRefreshView stopAnimating];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    isTableLoading = false;
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - ViewDidAppear - Finished");}
}


#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */
-(void)dataSuccessfullyReceived
{
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - didSelectRowAtIndexPath - Start");}

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    myIndex = indexPath.row;
    
    //Set the singleton string equal to selected group ID
    [NetworkCommunication sharedManager].stringSelectedGroupID = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).groupID;
    //and the number of users in the selected group
//#pragma message "how about a convenience function on the NetworkCommunication class that does this line for you?"
    [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople =[(NSNumber*)((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).numberOfPeople intValue];
    [NetworkCommunication sharedManager].stringCurrentDB = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).dbID;
    [NetworkCommunication sharedManager].intSelectedGroupProgressIndex = [(NSNumber*)((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).groupIndex intValue];
    
    // URL
    //#pragma message "Backend Access should be moved into separate class"
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/groups/%@",
                                                    ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).groupID];
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
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"GroupTable - numberOfRowsInSection - Start");
        NSLog(@"GroupTable - numberOfRowsInSection - Finished");
    }

    return [NetworkCommunication sharedManager].arrayOfGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - cellForRowAtIndexPath - Start");}

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIView *backgroundView = (UIImageView *)[cell viewWithTag:10];
    backgroundView.clipsToBounds = YES;
    backgroundView.layer.cornerRadius = backgroundView.frame.size.height/2.0;
    backgroundView.layer.borderWidth = 2;
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[ ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).imageID stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
//    cell.backgroundView.alpha = .2;
    
    UIImageView *firstImageView = (UIImageView *)[cell viewWithTag:5];
    firstImageView.image = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).imageID;
    
    for(int i = 0; i < ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).friendPics.count;i++)
    {
        UIImageView *nextImageView = (UIImageView *)[cell viewWithTag:6+i];
        nextImageView.image = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).friendPics[i];
    }
    //Facebook connection used for profile picture
//    cell.imageView.image = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).imageID;
//    
//    //Code to display badge that appears next to the group
//    cell.textLabel.text = [NSString stringWithFormat:@"%@'s Group Event",((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).ownerName];
//    cell.badgeString = [NSString stringWithFormat:@"%@",((Group*)[NetworkCommunication sharedManager].arrayOfGroups[indexPath.row]).groupIndex];
//    cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
//    cell.badge.radius = 9;
//    cell.badge.fontSize = 18;
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"GroupTable - cellForRowAtIndexPath - Finished");}
    return cell;
}

#pragma mark - Heroku Communication
/**
 * --------------------------------------------------------------------------
 *  Heroku
 * --------------------------------------------------------------------------
 */

- (IBAction)reloadData:(id)sender
{
    
    //[self getGoogle];
    [self resetEverything];
    //[self yesWith:3 andUrl:@"543482c59b6f750200271e81"];
    
}

- (IBAction)logOutPressed:(id)sender {
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        [self performSegueWithIdentifier:@"logout" sender:self];
        [NetworkCommunication sharedManager].controllerCurrentGroup = nil;
    }
    
}



- (void)deleteGroup:(NSString *)pplid
               with:(NSString *)myId
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/ppl/%@groups/%@", pplid, myId];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
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
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/groups/%@", str];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
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
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/groups"];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger responseStatusCode = [httpResponse statusCode];

      if (responseStatusCode == 200 && data)
      {
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              NSArray *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

              //self.myGroups = [NSMutableArray array];
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
}

- (void)resetPeople:(NSString *)pplid
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/ppl/%@groups", pplid];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];

    //Data Task Block
    NSURLSessionDataTask *dataTask =
        [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger responseStatusCode = [httpResponse statusCode];

      if (responseStatusCode == 200 && data)
      {
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

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
}

//Only for testing purposes
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
    
    //URL
    NSString *fixedURL = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/google/food"];
    NSURL *url = [NSURL URLWithString:fixedURL];
    
    //Request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    //Data Task
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         if (responseStatusCode == 200 && data)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
             {
                 // Creates local data for yelp info
                 NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
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
    
}

#pragma mark - Facebook
/**
 * --------------------------------------------------------------------------
 * Facebook
 * --------------------------------------------------------------------------
 */

-(void)downloadImages
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error)
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
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"AddGroup"])
    {
//        FriendTableViewController *controller = [segue destinationViewController];
//        controller.parent = self;
    }
    else if ([segue.identifier isEqualToString:@"ToSwiping"])
    {
        DraggableBackground *controller = [segue destinationViewController];
        controller.groupID = ((Group*)[NetworkCommunication sharedManager].arrayOfGroups[myIndex]).groupID;
    }
    else if ([segue.identifier isEqualToString:@"BackToSwiping"])
    {
        
    }
    
}

- (IBAction)unwindToFriendTableViewController:(UIStoryboardSegue *)unwindSegue
{
    [self tableWillReload];
}

- (IBAction)unwindToSwiping:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
