//
//  NetworkCom.m
//  TFE
//
//  Created by Luke Solomon on 10/8/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "NetworkCom.h"
#import "Global.h"

@implementation NetworkCom

/**
 *  This is the singleton
 *
 *  @param urlID        The url that the requests are coming from
 *  @param requestID    This is the type of request
 *  @param dictionaryID The dictionary we are trying to access
 */
- (void)getRequests:(NSString *)urlID
               type:(NSString *)requestID
     whatDictionary:(NSDictionary*)dictionaryID
{
    //param 1
    // URL
    
    NSString *fixedUrl = HEROKU_URL;
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
     // Session Config
     NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
     NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config
                                                              delegate:self
                                                         delegateQueue:nil];
    
    // Request
    //param 2

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:requestID];
    
    
    // Dictionary
    // code, groupID, nil
    //param 3
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: code, @"groupID", nil];
    
    // Error handling
    NSError *error = nil;
    // NSData conversion
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:kNilOptions
                                                     error:&error];
    
    
    if (requestID == "GET")
    {
        
    }
    
    else if (requestID == "DELETE")
    {
        
    }
    
    // Data Task Block
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request
                  completionHandler:^(       NSData *data,
                                      NSURLResponse *response,
                                            NSError *error )
     {
         // HTTP Response
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         // Status Code
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         // if success check
         if (responseStatusCode == 200 && data)
         {
             dispatch_async( dispatch_get_main_queue(), ^( void )
                            {
                                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                       options:0
                                                                                         error:nil];
                                
                                self.myGroups = [NSMutableArray array];
                                
                                for ( int i = 0; i < fetchedData.count; i++ )
                                {
                                    NSDictionary *data1 = [fetchedData objectAtIndex:i];
                                    [self.myGroups addObject:data1[@"groupID"]];
                                }
                                
                                [self.tableView reloadData];
                            });
             
             // do something with this data
             // if you want to update UI, do it on main queue
         }
         else
         {
             // error handling
             NSLog( @"gucci" );
         }
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
