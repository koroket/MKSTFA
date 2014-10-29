//
//  FriendTableViewController.h
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableViewController : UITableViewController

@property (nonatomic,assign) bool didLoadForFirstTime;
-(void)dataSuccessfullyReceived;
-(void)tableDidReload;
@end
