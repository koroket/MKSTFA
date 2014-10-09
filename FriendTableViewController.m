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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myGroups = [NSMutableArray array];
    self.numOfPeople = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRequests];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return self.myGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.myGroups objectAtIndex:indexPath.row];
    
    return cell;
}

- (IBAction)unwindToFriendTableViewController:(UIStoryboardSegue*)unwindSegue {
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddGroup"]) {
        ListOfFriendsTableViewController *controller = [segue destinationViewController];
        controller.parent = self;
        
    }else if ([segue.identifier isEqualToString:@"Swipe"]) {
        SwipeViewController *controller = [segue destinationViewController];
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        controller.groupID = [self.myGroups objectAtIndex:selectedIndexPath.row];
        controller.numOfPeople = (int)[self.numOfPeople objectAtIndex:selectedIndexPath.row];
        
    }
}
-(void)getRequests
{
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups",[[NSUserDefaults standardUserDefaults] stringForKey:@"myId"]];
    // 1
    
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.myGroups = [NSMutableArray array];
                for(int i = 0;i<fetchedData.count;i++)
                {
                    NSDictionary *data1  = [fetchedData objectAtIndex:i];
                    [self.myGroups addObject:data1[@"groupID"]];
                    //[self deleteGroup:data1[@"_id"]];
                    [self.numOfPeople addObject:data1[@"number"]];
                    
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
    //[self yesWith:3 andUrl:@"543482c59b6f750200271e81"];
}
-(void)yesWith:(int)index andUrl:(NSString*) tempUrl
{
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@/%d",tempUrl, index];
    // 1
    NSURL *url = [NSURL URLWithString:fixedUrl];
    // 1
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"PUT"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (1==1||responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSNumber *a = fetchedData[@"agree"];
                int t = [a intValue];
                if(t==3)
                {
                    [self performSegueWithIdentifier:@"Done" sender:self];
                }
            });
            
            // do something with this data
            // if you want to update UI, do it on main queue
        } else {
            // error handling
            NSLog([NSString stringWithFormat:@"Error, status code:%ld", (long)responseStatusCode]);
        }
    }];
    [dataTask resume];
    
}

-(void)deleteGroup:(NSString*) myId
{
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups/%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"myId"],myId];
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

-(void)deleteIndividualGroup:(NSString*) str
{
    
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@",str];
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

@end