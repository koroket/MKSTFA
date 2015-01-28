//
//  NetworkCommunication.h
//  TFE
//
//  Created by Luke Solomon on 10/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLogInViewController.h"
#import "GroupTableViewController.h"
#import "Card.h"

@interface NetworkCommunication : NSObject
@property NSString *HerokuURL;
@property NSData *myData;

+ (instancetype)sharedManager;

-(void)serverRequests:(NSString *)urlID type:(NSString *)requestID whatDictionary:(NSDictionary*)dictionaryID withBlock:(void (^)())blockName;
-(void)getRequests;
-(void)linkDeviceToken;

//Strings
@property NSString *stringFBUserId;
@property NSString *stringFBUserName;
@property NSString *stringDeviceToken;
@property NSString *stringSelectedGroupID;
@property NSString *stringYelpSearchTerm;
@property NSString *stringCurrentDB;
@property NSString *stringYelpLocation;
@property NSString *stringCurrentLatitude;
@property NSString *stringCurrentLongitude;

//integers
@property int intSelectedGroupNumberOfPeople;
@property int intYelpNumberOfLocations;
@property int intSelectedGroupProgressIndex;

//Arrays
@property NSMutableArray *arraySelectedGroupCardData;
@property NSMutableArray *arraySelectedGroupDeviceTokens;

//Arrays-group
@property (nonatomic,strong) NSMutableArray* arrayOfGroups;

//Controllers
@property FBLogInViewController  *controllerCurrentLogin;
@property GroupTableViewController *controllerCurrentGroup;

//Booleans
@property BOOL boolDebug;
@property BOOL initialLoading;
@property BOOL searchTermDidChange;

//Card
@property (nonatomic, strong) Card* currentCard;

@property (nonatomic, assign) double minRating;
@property (nonatomic, assign) double maxDistance;
@property (nonatomic, assign) int maxPrice;

@end
