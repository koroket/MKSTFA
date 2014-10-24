//
//  NetworkCommunication.h
//  TFE
//
//  Created by Luke Solomon on 10/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HerokuCommunication : NSObject

+ (instancetype)sharedManager;

- (void)serverRequests:(NSString *)urlID
                  type:(NSString *)requestID
        whatDictionary:(NSDictionary*)dictionaryID
             withBlock:(void (^)())blockName;

//Strings
@property NSString *stringFBUserId;
@property NSString *stringFBUserName;
@property NSString *stringDeviceToken;
@property NSString *stringSelectedGroupID;
@property NSString *stringYelpSearchTerm;
@property NSString *stringYelpLocation;
@property NSString *stringCurrentDB;
@property NSString *HerokuURL;

//integers
@property int intSelectedGroupNumberOfPeople;
@property int intYelpNumberOfLocations;

//Arrays
@property NSMutableArray *arraySelectedGroupCardData;
@property NSMutableArray *arraySelectedGroupDeviceTokens;

//Data
@property NSData *myData;

@end
