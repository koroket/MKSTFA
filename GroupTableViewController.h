//
//  FriendTableViewController.h
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *myGroups;
#pragma message "in Obj-C you should use expressive property/variable names, e.g. 'numberOfPeople'"
@property (nonatomic, strong) NSMutableArray *numOfPeople;

@end
