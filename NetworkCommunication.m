//
//  NetworkCom.m
//  TFE
//
//  Created by Luke Solomon on 10/8/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "NetworkCommunication.h"

@implementation NetworkCommunication 



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
           withSelf:(NSObject*)selfRef
          withBlock:(void (^)())blockName
{
    //param 1 - URL
    
    _HerokuURL = @"http://young-sierra-7245.herokuapp.com/groups/%@";
    
    NSString *fixedUrl = _HerokuURL;
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    // Session Config
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config
                                                             delegate:selfRef
                                                        delegateQueue:nil];
    
   
    //param 2 - Request
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:requestID];
    
    
    //param 3 - Dictionary
    
    // NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: code, @"groupID", nil];
    
    //Error handling
    NSError *error = nil;
    //NSData conversion
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaryID
                                                   options:kNilOptions
                                                     error:&error];
    // Data Task Block
    
    [blockName resume];
}

- (void) postMethods
{
    
}

- (void) deleteMethods
{
    
}

@end
