//
//  Card.h
//  TFE
//
//  Created by sloot on 11/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * rating;
@property (nonatomic, retain) NSString * hours;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData* image;
@property (nonatomic, retain) NSString * categories;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * bizid;
@property (nonatomic, retain) NSString * city;

@end
