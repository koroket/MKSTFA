//
//  YelpCommunication.m
//  TFE
//
//  Created by Luke Solomon on 10/24/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "YelpCommunication.h"
#import "HerokuCommunication.h"


@interface YelpCommunication ()

//properties
@property(nonatomic, strong) NSMutableArray *selectedFriends;
//dictionary
@property(nonatomic, strong) NSMutableDictionary *dictionary;

@end


@implementation YelpCommunication
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
    static YelpCommunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedMyManager = [[self alloc] init];
                  });
    return sharedMyManager;
}


#pragma mark - Yelp Server Communication
/**
 * --------------------------------------------------------------------------
 * Yelp
 * --------------------------------------------------------------------------
 */

- (void)collectTokens
{
    for(int i = 0; i < self.selectedFriends.count; i++)
    {
        //        [NetworkCommunication getUserIDTokens:self.selectedFriends[i]];
    }
}

- (void)getYelp
{
    if (self.selectedFriends.count > 1)
    {
        //URL
        NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%@/%d",
                              @"PaloAlto",
                              [HerokuCommunication sharedManager].stringYelpSearchTerm,
                              [HerokuCommunication sharedManager].intYelpNumberOfLocations
                              ];
        NSURL *url = [NSURL URLWithString:fixedURL];
        //Request
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:30.0];
        [request setHTTPMethod:@"GET"];
        //Session
        NSURLSession *urlSession = [NSURLSession sharedSession];
        //Data Task
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
    #pragma message "This section needs more comments, ideally you should describe what is going on here on a conceptual level"
                        // Creates local data for yelp info
                        NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:0
                                                                                      error:nil];
                        NSArray *buisinesses = [NSArray array];
                        buisinesses = fetchedData[@"businesses"];
                        // Creates array of empty replies
                        NSMutableArray *tempReplies = [NSMutableArray array];
                        for (int i = 0; i < buisinesses.count; i++)
                        {
                            [tempReplies addObject:[NSNumber numberWithInt:0]];
                        }
                        // Creates Decision Objects
                        NSMutableArray *decisionObjects = [NSMutableArray array];
                        // insert object info here
                        for (int i = 0; i < buisinesses.count; i++)
                        {
                            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                            NSDictionary *dictionary = [buisinesses objectAtIndex:i];
                            [temp setObject:dictionary[@"name"] forKey:@"Name"];
                            if(dictionary[@"image_url"]!=nil)
                            {
                                [temp setObject:dictionary[@"image_url"] forKey:@"ImageURL"];
                            }
                            [decisionObjects addObject:temp];
                        }
                        
                        //Dictionary Handling
                        //Device tokens
                        [self.dictionary setValue:self.myTokens forKey:@"Tokens"];
                        //Sets DONE
                        [self.dictionary setValue:@(-1) forKey:@"Done"];
                        //Sets the business count
                        [self.dictionary setValue:@(buisinesses.count) forKey:@"Number"];
                        //Sets the replies
                        [self.dictionary setValue:tempReplies forKey:@"Replies"];
                        //Sets the decision objects
                        [self.dictionary setValue:decisionObjects forKey:@"Objects"];
                        //Creates the group
                        [self createNewGroup];
                    });
                 //where to stick dispatch to main queue
             }
             else
             {
                 // error handling
                 NSLog(@"Yelp Failed");
             }
         }];//Data Task Block
        [dataTask resume];
    }
    else
    {
        NSLog(@"You didnt select any friends");
    }
}

@end
