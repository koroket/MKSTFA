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

@interface FriendTableViewController()

@property (nonatomic,strong) NSMutableArray *myFriends;
@property (nonatomic,strong) NSMutableArray *friendIds;
@property (nonatomic,strong) NSMutableArray *selectedFriends;
@property (nonatomic,strong) NSMutableDictionary* dictionary;

@end

@implementation FriendTableViewController{}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFromFacebook];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)loadFromFacebook
{
    self.dictionary = [NSMutableDictionary dictionary];
    self.myFriends = [NSMutableArray array];
    self.friendIds = [NSMutableArray array];
    self.selectedFriends = [NSMutableArray array];
    
    
    [FBRequestConnection startWithGraphPath:@"/me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        
        NSDictionary *resultDictionary = (NSDictionary*)result;
        
        NSArray *data = [resultDictionary objectForKey:@"data"];
        
        for(NSDictionary *dic in data)
        {
            [self.myFriends addObject:[dic objectForKey:@"name"]];
            [self.friendIds addObject:[dic objectForKey:@"id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
            
        });
        
      
        
        
        
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 ==========================================================================================================================================================
 #pragma mark - Table view data source
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.candies removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        
        [self.selectedFriends removeObject:[self.friendIds objectAtIndex:indexPath.row]];
        
    } else {
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self.selectedFriends addObject:[self.friendIds objectAtIndex:indexPath.row]];
        
    }
    
    NSLog(@"These are the selected friends %@", self.selectedFriends);
    
}

/*
==========================================================================================================================================================
 */




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    [self.selectedFriends addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"myId"]];
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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
    if ([segue.identifier isEqualToString:@"Details"]) {
        
    } else if ([segue.identifier isEqualToString:@"unwindToFriend"]) {

        [self getYelp];
    }
}


-(void)sendNewGroupsWithGroupCode:(NSString *)code
{

        for(int i = 0; i<self.selectedFriends.count; i++)
        {
            NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/ppl/%@groups",[self.selectedFriends objectAtIndex:i]];
            // 1
            NSURL *url = [NSURL URLWithString:fixedUrl];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            
            // 2
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            request.HTTPMethod = @"POST";
            
            
            // 3
            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        code,
                                        @"groupID",
                                        @(self.selectedFriends.count),
                                        @"number",
                                        nil];

           
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:kNilOptions error:&error];
            
            if (!error) {
                // 4
                NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                           fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                               
                                                                               
                                                                               
                                                                           }];
                
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
-(void)createNewGroup
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
                                                       options:kNilOptions error:&error];
        
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
        else
        {
            NSLog(@"Cannot connect to server");
        }

    
}


-(void)getYelp
{
    if(self.selectedFriends.count>1)
    {
        NSString* fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/yeah",[[NSUserDefaults standardUserDefaults] stringForKey:@"location"]];
    NSURL *url = [NSURL URLWithString:fixedURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Creates local data for yelp info
                NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *buisinesses = [NSArray array];
                buisinesses =  fetchedData[@"businesses"];
                
                int replaceNumberForNumOfPeople = 20;
                
                //Creates array of empty replies
                NSMutableArray* tempReplies = [NSMutableArray array];
                for(int i = 0; i<replaceNumberForNumOfPeople;i++)
                {
                    [tempReplies addObject:[NSNumber numberWithInt:0]];
                }

                //Creates Decision Objects
                NSMutableArray *decisionObjects = [NSMutableArray array];
                
                //insert object info here
                for(int i = 0; i< replaceNumberForNumOfPeople; i++)
                {
                    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
                    NSDictionary* dictionary = [buisinesses objectAtIndex:i];
                    
                    [temp setObject:dictionary[@"name"] forKey:@"Name"];
                    
                    [decisionObjects addObject:temp];
                }
                

                
                // 3
                [self.dictionary setValue:@(false) forKey:@"Done"];
                [self.dictionary setValue:@(replaceNumberForNumOfPeople) forKey:@"Number"];
                [self.dictionary setValue:tempReplies forKey:@"Replies"];
                [self.dictionary setValue:decisionObjects forKey:@"Objects"];
                

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
    else
    {
        NSLog(@"You didnt select any friends");
    }
}
- (IBAction)unwindToSelfViewController:(UIStoryboardSegue*)unwindSegue {
    
}
@end
