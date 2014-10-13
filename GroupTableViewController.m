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


@interface GroupTableViewController ()

- (IBAction)reloadData:(id)sender;
@property (nonatomic,strong) NSMutableArray* myOwners;

@end

@implementation GroupTableViewController
{
    int myIndex;
}

#pragma init
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
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
    [[NSUserDefaults standardUserDefaults] setObject:[self.myGroups objectAtIndex:indexPath.row] forKey:@"pract"];
    int tempint = [(NSNumber*)self.numOfPeople[indexPath.row] intValue];
    [[NSUserDefaults standardUserDefaults] setInteger:tempint forKey:@"numOfPeople"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        NSInteger responseStatusCode = [httpResponse statusCode];

        if (responseStatusCode == 200 && data)
        {
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              NSArray *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

              [[NSUserDefaults standardUserDefaults] setObject:fetchedData forKey:@"AllObjects"];

              [[NSUserDefaults standardUserDefaults] synchronize];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"%@'s Group Event",[self.myOwners objectAtIndex:self.myOwners.count-1-indexPath.row]];

    return cell;
}

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
- (void)getRequests
{
    // URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups",
                                                    [[NSUserDefaults standardUserDefaults] stringForKey:@"myId"]];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];

    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
        [urlSession dataTaskWithRequest:request
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                          NSInteger responseStatusCode = [httpResponse statusCode];

                          if (responseStatusCode == 200 && data)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                  NSArray *fetchedData =
                                      [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                  self.myGroups = [NSMutableArray array];
                                  for (int i = 0; i < fetchedData.count; i++)
                                  {
                                      NSDictionary *data1 = [fetchedData objectAtIndex:i];
                                      [self.myGroups addObject:data1[@"groupID"]];
                                      //[self deleteGroup:data1[@"_id"]];
                                      [self.numOfPeople addObject:data1[@"number"]];
                                      [self.myOwners addObject:data1[@"owner"]];
                                  }

                                  [self.tableView reloadData];
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  
                              });

                              // do something with this data
                              // if you want to update UI, do it on main queue
                          }
                          else
                          {
                              // error handling
                              NSLog(@"gucci");
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                             
                          });
                      }];
    [dataTask resume];
}

- (IBAction)reloadData:(id)sender
{
    [self getRequests];
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
              NSDictionary *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:nil];
              NSNumber *a = fetchedData[@"agree"];
              int t = [a intValue];
              if (t == 3)
              {
                  [self performSegueWithIdentifier:@"Done"
                                            sender:self];
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
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger responseStatusCode = [httpResponse statusCode];

      if (responseStatusCode == 200 && data)
      {
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              NSArray *fetchedData =
                  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

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
@end
