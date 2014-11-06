//
//  HerokuCommunication
//  TFE
//
//  Created by Luke Solomon on 10/8/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "NetworkCommunication.h"
#import "YelpCommunication.h"
#import "Group.h"

@interface NetworkCommunication ()

@property(nonatomic,strong) NSMutableArray *myTokens;
@property(nonatomic, strong) NSMutableArray *selectedFriends;

@end

@implementation NetworkCommunication
{
    int counter;
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

+ (instancetype)sharedManager
{
    static NetworkCommunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
      {
          sharedMyManager = [[self alloc] init];
      });
    return sharedMyManager;
}

- (void)dealloc
{
    // Should never be called, but just here for clarity really.
}

#pragma mark - Heroku Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

/**
 *  This is the singleton
 *
 *  @param urlID        The url that the requests are coming from
 *  @param requestID    This is the type of request
 *  @param dictionaryID The dictionary we are trying to access
 */
- (void)serverRequests:(NSString *)urlID
               type:(NSString *)requestID
     whatDictionary:(NSDictionary*)dictionaryID
          withBlock:(void (^)())blockName
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"NetworkCommunication - HerokuRequests - Start");}

    //param 1 - URL
    _HerokuURL = @"http://young-sierra-7245.herokuapp.com/";
    
    NSString *fixedUrl = [NSString stringWithFormat:@"%@%@",_HerokuURL,urlID];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    // Session Config
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    //param 2 - Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:requestID];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler: ^void (NSData *data,NSURLResponse *response, NSError *error)
    {
        self.myData = data;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger responseStatusCode = [httpResponse statusCode];

        if (responseStatusCode == 200 && data)
        {
          dispatch_async(dispatch_get_main_queue(), blockName);
          // do something with this data
          // if you want to update UI, do it on main queue
        }
        else
        {
          // error handling
          NSLog(@"NetworkCommunication - HerokuRequests - ERROR: Heroku (are you connected to the internet?");
        }
    }];
    
    [dataTask resume];
    
    if ([NetworkCommunication sharedManager].boolDebug == true) {NSLog(@"NetworkCommunication - HerokuRequests - Finished");}
}

/**
 *  Fixes the string from the send notification class
 *
 *  @param str - the FBusername that gets appended to the heroku URL
 *
 *  @return returns the string that is fixed
 */
-(NSString*)stringfix:(NSString*) str
{
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return temp;
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
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/push/%@/%@", tempToken, [self stringfix:[NetworkCommunication sharedManager].stringFBUserName]];
    
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
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
            NSLog(@"GroupTable - getRequests - ERROR SEND NOTIFICATION");
        }
        dispatch_async(dispatch_get_main_queue(), ^
        {
                
        });
     }];
    [dataTask resume];
}

- (void)getRequests
{
    if ([NetworkCommunication sharedManager].boolDebug == true) {
        NSLog(@"GroupTable - getRequests - Start");
    }
    NetworkCommunication *sharedCommunication = [NetworkCommunication alloc];
    [sharedCommunication serverRequests: [NSString stringWithFormat:@"ppl/%@groups", [NetworkCommunication sharedManager].stringFBUserId] type:@"GET"whatDictionary:nil withBlock:^(void)
     {
         self.arrayOfGroups = [NSMutableArray array];
         NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:sharedCommunication.myData options:0 error:nil];
         for (int i = 0; i < fetchedData.count; i++)
         {
             Group* newGroup = [[Group alloc] init];
             NSDictionary *data1 = [fetchedData objectAtIndex:i];
             
             newGroup.groupID = data1[@"groupID"];
             newGroup.numberOfPeople = data1[@"number"];
             newGroup.ownerName = data1[@"owner"];
             newGroup.ownerID = data1[@"ownerID"];
             newGroup.dbID = data1[@"_id"];
             newGroup.groupIndex = data1[@"currentIndex"];
             
             [self.arrayOfGroups addObject:newGroup];
         }
         [self downloadImages];
     }];
    if ([NetworkCommunication sharedManager].boolDebug == true)
    {
        NSLog(@"GroupTable - getRequests - Finished");
    }
}

-(void)downloadImages
{
    for(int i = 0; i < self.arrayOfGroups.count; i++)
    {
        counter = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^
        {
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",((Group*)self.arrayOfGroups[i]).ownerID];
            UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
            ((Group*)self.arrayOfGroups[i]).imageID = tempImage;
            counter++;
            dispatch_async(dispatch_get_main_queue(), ^
            {
              if(counter==self.arrayOfGroups.count)
              {
                  if([NetworkCommunication sharedManager].controllerCurrentGroup == nil)
                  {
                      [self.controllerCurrentLogin performSegueWithIdentifier:@"loggedin" sender:self.controllerCurrentLogin];
                  }
                  else
                  {
                      [[NetworkCommunication sharedManager].controllerCurrentGroup tableDidReload];
                  }
              }
            });
        });
    }
    if(self.arrayOfGroups.count==0)
    {
        if([NetworkCommunication sharedManager].controllerCurrentGroup == nil)
        {
            [self.controllerCurrentLogin performSegueWithIdentifier:@"loggedin" sender:self.controllerCurrentLogin];
        }
        else
        {
            [[NetworkCommunication sharedManager].controllerCurrentGroup tableDidReload];
        }
    }
}

- (void)linkDeviceToken
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/%@token", [NetworkCommunication sharedManager].stringFBUserId];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    //Session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    //Dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NetworkCommunication sharedManager].stringDeviceToken, @"token", nil];
    //errorHandling
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    if (!error)
    {
        //Upload
        NSURLSessionUploadTask *uploadTask =
        [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
         {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             NSInteger responseStatusCode = [httpResponse statusCode];
             if (responseStatusCode == 200 && data)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                 {
                    NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSDictionary *data1 = [fetchedData objectAtIndex:0];
                 });
             }
         }];
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else
    {
        NSLog(@"Cannot connect to server");
    }
}
@end
