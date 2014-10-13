//
//  Pushbots.h
//  Pushbots framework 1.0.5.5
//
//  Created by Abdullah Diaa on 23/09/14.
//  Copyright (c) 2014 PushBots Inc. All rights reserved.
//

@class Pushbots;
@class CLLocation;

@interface Pushbots : NSObject

/** @name PushBots Connection */
+(Pushbots *)getInstance;

/** @name PushBots Options */

- (void) RegisterDeviceToken:(NSData *)deviceToken;

-(NSString *) getDeviceID;
/*!
 Send device location to PushBots servers.
 @param location: Device location [CLLocation]
 */
-(void) sendLocation: (CLLocation *) location;
/*!
 Send device Lat/Lng to PushBots servers.
 @param lat: Device Latitude [NSString]
 @param lng: Device Longitude [NSString]
 */
-(void) sendLocationLat: (NSString *) lat withLng:(NSString *) lng;
/*!
 Send device Alias[username] to PushBots servers.
 @param alias: Device alias[username]
 */
-(void) sendAlias: (NSString *) alias;
/*!
 Tag/untag the device on PushBots servers.
 @param tag: Device tag
 */
-(void) tag:(NSString *)tag ;
-(void) untag:(NSString *)tag ;
-(void) unregister;

/*!
 Set device Badge count on servers.
 @param count: Custom badge count
 */
-(void) badgeCount:(NSString *)count ;
-(void) setBadgeCount:(NSString *)count ;
/*!
 decrease badge count.
 @param count: badge count to decrease
 */
-(void) decreaseBadgeCountBy:(NSString *)count ;
/*!
 Reset badge count to ZERO.
 */
-(void) resetBadgeCount;


/** @name PushBots Analytics */
/*!
 Record Notification opened on servers.
 */
-(void) OpenedNotification;

@end
