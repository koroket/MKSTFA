//
//  ListOfFriendsTableViewController.h
//  TFE
//
//  Created by sloot on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupTableViewController;

@interface FriendTableViewController : UITableViewController

@property (nonatomic, retain) GroupTableViewController *parent;

@end
