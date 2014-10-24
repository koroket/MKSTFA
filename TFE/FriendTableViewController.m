//
//  FriendTableViewController
//  CandyStore
//
//  Created by sloot on 9/16/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "FriendTableViewController.h"
#import "GroupTableViewController.h"
#import "NetworkCommunication.h"
#import "MBProgressHUD.h"
#import "Group.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendTableViewController ()

//properties
@property(nonatomic, strong) NSMutableArray *myFriends;
@property(nonatomic, strong) NSMutableArray *friendIds;
@property(nonatomic, strong) NSMutableArray *selectedFriends;

//methods
- (IBAction)unwind:(id)sender;

@end

@implementation FriendTableViewController
{
    
}

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadFromFacebook];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];

    [self.selectedFriends addObject:[NetworkCommunication sharedManager].stringFBUserId];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Friends";
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table View Data Source
 * --------------------------------------------------------------------------
 */

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
	return [self.myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	cell.textLabel.text = self.myFriends[indexPath.row];


	return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    #pragma message "You should consider checking against the list of friendIDs to see if this row is already selected. Checking against the acessoryType of a cell isn't a very elegant solution"
	if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
    {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
		[self.selectedFriends removeObject:[self.friendIds objectAtIndex:indexPath.row]];
	}
	else
    {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[self.selectedFriends addObject:[self.friendIds objectAtIndex:indexPath.row]];
	}
	NSLog(@"These are the selected friends %@", self.selectedFriends);
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Details"])
    {
    }
    else if ([segue.identifier isEqualToString:@"Unwind"])
    {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (IBAction)unwindToSelfViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

- (IBAction)unwind:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    [self collectTokens];

}

@end
