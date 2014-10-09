//
//  Group.h
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (nonatomic, strong) NSMutableArray *friendsInGroup;
@property (nonatomic, retain) NSString *name;

@end
