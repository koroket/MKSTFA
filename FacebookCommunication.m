//
//  FacebookCommunication.m
//  TFE
//
//  Created by Luke Solomon on 10/24/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FacebookCommunication.h"

@interface FacebookCommunication ()

//properties
@property(nonatomic, strong) NSMutableArray *myFriends;
@property(nonatomic, strong) NSMutableArray *friendIds;
@property(nonatomic, strong) NSMutableArray *selectedFriends;

@end

@implementation FacebookCommunication
{
    
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

+ (instancetype)sharedManager
{
    static FacebookCommunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedMyManager = [[self alloc] init];
                  });
    return sharedMyManager;
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
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            
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
                                    [HerokuCommunication sharedManager].stringFBUserName, @"owner",
                                    [HerokuCommunication sharedManager].stringFBUserId, @"ownerID",
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
}

/**
 *  Creates the actual group itself
 */
#pragma message "Also this method should probably not be part of this ViewController and instead should be moved into a backend access class"
- (void)createNewGroup
{
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
}



@end
