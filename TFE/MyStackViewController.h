//
//  MyStackViewController.h
//  TFE
//
//  Created by Luke Solomon on 12/24/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyStackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray* cards;

@end
