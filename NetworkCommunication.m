//
//  HerokuCommunication
//  TFE
//
//  Created by Luke Solomon on 10/8/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "NetworkCommunication.h"
#import "YelpCommunication.h"

@interface NetworkCommunication ()

@property(nonatomic,strong) NSMutableArray *myTokens;
@property(nonatomic, strong) NSMutableArray *selectedFriends;

@end

@implementation NetworkCommunication
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
    //param 1 - URL
    _HerokuURL = @"http://young-sierra-7245.herokuapp.com/";
    
    NSString *fixedUrl = [NSString stringWithFormat:@"%@%@",_HerokuURL,urlID];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    // Session Config
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    //param 2 - Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:requestID];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request
                                                   completionHandler: ^void (NSData *data,
                                                                             NSURLResponse *response,
                                                                             NSError *error)
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
          NSLog(@"gucci");
        }
    }];

    //param 3 - Dictionary
    
    /*
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                  code,
                                  @"groupID",
                                  nil];
    */
    
    //Error handling
    // NSError *error = nil;
    //NSData conversion
    /*NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaryID
                                                    options:kNilOptions
                                                      error:&error];*/
    // Data Task Block
    
    [dataTask resume];
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
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" "
                                                    withString:@"_"];
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

- (void) postMethods
{
    
}

- (void) deleteMethods
{
    
}

@end
