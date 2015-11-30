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

@implementation NetworkCommunication {
    NSInteger counter;
    NSInteger numOfPicsToDownload;
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

+ (instancetype)sharedManager {
    static NetworkCommunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Heroku Server Communication
/**
 * --------------------------------------------------------------------------
 * Heroku
 * --------------------------------------------------------------------------
 */

- (void)serverRequests:(NSString *)urlID type:(NSString *)requestID whatDictionary:(NSDictionary*)dictionaryID withBlock:(void (^)())blockName {
    _HerokuURL = @"http://tinder-for-anything.herokuapp.com/";
    NSString *fixedUrl = [NSString stringWithFormat:@"%@%@",_HerokuURL,urlID];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:requestID];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler: ^void (NSData *data, NSURLResponse *response, NSError *error) {
        self.myData = data;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if (responseStatusCode == 200 && data) {
          dispatch_async(dispatch_get_main_queue(), blockName);
          // do something with this data
          // if you want to update UI, do it on main queue
        } else {
          // error handling
          NSLog(@"ERROR: Heroku");
        }
    }];
    [dataTask resume];
}

-(NSString*)stringfix:(NSString*) str {
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return temp;
}

- (void)sendNotification:(NSString*)tempToken {
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/token/push/%@/%@", tempToken, [self stringfix:[NetworkCommunication sharedManager].stringFBUserName]];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         if (responseStatusCode == 200 && data) {
             dispatch_async(dispatch_get_main_queue(), ^(void) {
             });
             // do something with this data
             // if you want to update UI, do it on main queue
         } else {
             NSLog(@"ERROR SEND NOTIFICATION");
         }
         dispatch_async(dispatch_get_main_queue(), ^ {
         });
    }];
    [dataTask resume];
}

- (void)getRequests {
    [self serverRequests: [NSString stringWithFormat:@"ppl/%@groups", [NetworkCommunication sharedManager].stringFBUserId] type:@"GET" whatDictionary:nil withBlock:^(void) {
        
         self.arrayOfGroups = [NSMutableArray array];
         NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:self.myData options:0 error:nil];
         
         for (int i = 0; i < fetchedData.count; i++) {
             Group* newGroup = [[Group alloc] init];
             
             NSDictionary *data1 = [fetchedData objectAtIndex:i];
             
             newGroup.friendPics = [NSMutableArray array];
             newGroup.groupID = data1[@"groupID"];
             newGroup.numberOfPeople = data1[@"number"];
             newGroup.ownerName = data1[@"owner"];
             newGroup.ownerID = data1[@"ownerID"];
             newGroup.dbID = data1[@"_id"];
             newGroup.groupIndex = data1[@"currentIndex"];
             newGroup.friendIDs = data1[@"friendID"];
             [self.arrayOfGroups addObject:newGroup];
         }
         [self downloadImages];
     }];
}

- (void)downloadImages {
    numOfPicsToDownload = 0;
    for (int i = 0; i < self.arrayOfGroups.count; i++) {
#pragma message "You shouldn't use 'magic numbers' all numbers should be declared as constants"
        
        if (((Group *)self.arrayOfGroups[i]).friendIDs.count < 4) {
            numOfPicsToDownload += ((Group*)self.arrayOfGroups[i]).friendIDs.count-1;
        } else {
            numOfPicsToDownload += 3;
        }
    }
    numOfPicsToDownload+=self.arrayOfGroups.count;
    counter = 0;
    for (int i = 0; i < self.arrayOfGroups.count; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^ {
           NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",((Group *) self.arrayOfGroups[i]).ownerID];
           UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
           ((Group*)self.arrayOfGroups[i]).imageID = tempImage;
           counter++;
           //NSLog(@"%d",counter);
           if (counter == numOfPicsToDownload) {
               dispatch_async(dispatch_get_main_queue(), ^ {
                  if([NetworkCommunication sharedManager].controllerCurrentGroup == nil) {
                      [self.controllerCurrentLogin performSegueWithIdentifier:@"loggedin" sender:self.controllerCurrentLogin];
                  }
                  else {
                      [[NetworkCommunication sharedManager].controllerCurrentGroup tableDidReload];
                  }
               });
           }
        });
    }
    for (int i = 0; i < self.arrayOfGroups.count; i++) {
        int j = 1;
        while (j < ((Group*)self.arrayOfGroups[i]).friendIDs.count && j < 3) {
            dispatch_async (dispatch_get_global_queue(0, 0), ^ {
                NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",((Group*)self.arrayOfGroups[i]).friendIDs[j]];
                UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                [((Group*)self.arrayOfGroups[i]).friendPics addObject:tempImage];
                counter++;
                //NSLog(@"%d",counter);
                if (counter == numOfPicsToDownload) {
                    
                   dispatch_async(dispatch_get_main_queue(), ^ {
                       
                      if ([NetworkCommunication sharedManager].controllerCurrentGroup == nil) {
                          
                          [self.controllerCurrentLogin performSegueWithIdentifier:@"loggedin" sender:self.controllerCurrentLogin];
                      } else {
                          [[NetworkCommunication sharedManager].controllerCurrentGroup tableDidReload];
                      }
                   });
               }
            });
            j++;
        }
    }
    if (self.arrayOfGroups.count == 0) {
        if ([NetworkCommunication sharedManager].controllerCurrentGroup == nil) {
            [self.controllerCurrentLogin performSegueWithIdentifier:@"loggedin" sender:self.controllerCurrentLogin];
        } else {
            [[NetworkCommunication sharedManager].controllerCurrentGroup tableDidReload];
        }
    }
}

- (void)linkDeviceToken {
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/token/%@token", [NetworkCommunication sharedManager].stringFBUserId];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NetworkCommunication sharedManager].stringDeviceToken, @"token", nil];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             NSInteger responseStatusCode = [httpResponse statusCode];
             if (responseStatusCode == 200 && data) {
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                     NSDictionary *data1 = [fetchedData objectAtIndex:0];
                 });
             }
        }];
        [uploadTask resume];
        //NSLog(@"Connected to server");
    } else {
        //NSLog(@"Cannot connect to server");
    }
}
@end
