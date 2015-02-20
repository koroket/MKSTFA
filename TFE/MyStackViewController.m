//
//  MyStackViewController.m
//  TFE
//
//  Created by Luke Solomon on 12/24/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "MyStackViewController.h"
#import "AppDelegate.h"
#import "Card.h"
#import "NetworkCommunication.h"

@interface MyStackViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyStackViewController {
    NSMutableDictionary* sections;
    NSMutableArray* sectionNames;
    NSMutableArray* mutableArrayCards;
}

#pragma mark - Object Lifecycle
/**
 * --------------------------------------------------------------------------
 * Object Lifecycle
 * --------------------------------------------------------------------------
 */

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    sectionNames = [NSMutableArray array];
    sections = [NSMutableDictionary dictionary];
    if (self) {
        [self updateSectionsAndCards];
    }
    return self;
}

- (void)updateSectionsAndCards {
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    //wipe the 
    sections = [NSMutableDictionary dictionary];
    sectionNames = [NSMutableArray array];
    
    NSArray* cardArray = [context executeFetchRequest:fetchRequest error:&error];
    mutableArrayCards = [cardArray mutableCopy];
    for(int i = 0; i < mutableArrayCards.count; i++) {
        if( sections[ ((Card*) mutableArrayCards[i]).city ] == nil) {
            sections[ ( (Card*) mutableArrayCards[i]).city ] = [ NSMutableArray arrayWithObjects:mutableArrayCards[i], nil ];
            [ sectionNames addObject:( (Card*) mutableArrayCards[i]).city ];
        } else {
            [ (NSMutableArray*)sections [ ( (Card*) mutableArrayCards[i]).city] addObject:mutableArrayCards[i] ];
        }
    }
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"updateSectionsAndCards - MutableArrayCards:%@", mutableArrayCards);
    }
    
}

#pragma mark - UIViewController Overrides
/**
 * --------------------------------------------------------------------------
 * UIViewController Overrides
 * --------------------------------------------------------------------------
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSectionsAndCards];
    
    //change the color of the tab bar icon
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"StackIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Table view data source
/**
 * --------------------------------------------------------------------------
 * Table view data source
 * --------------------------------------------------------------------------
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [sectionNames objectAtIndex:indexPath.section];
    NSMutableArray *sectionCards = [sections objectForKey:sectionTitle];
    [NetworkCommunication sharedManager].currentCard = [sectionCards objectAtIndex:indexPath.row];
}

// Section Header Functions

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* sectionHeaderUIView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, tableView.frame.size.width, 20))];
    UILabel* sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    
    UIFont *headerFont = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    
    //sectionHeaderLabel.text = @" something ";
    sectionHeaderLabel.text = [sectionNames objectAtIndex:section];
    sectionHeaderLabel.textAlignment = NSTextAlignmentCenter;
    sectionHeaderLabel.textColor = [UIColor whiteColor];
    sectionHeaderLabel.font = headerFont;
    //sectionHeaderLabel.text = @" %@",[sectionNames objectAtIndex:section];
    [sectionHeaderUIView addSubview:sectionHeaderLabel];
    sectionHeaderUIView.backgroundColor = nil;
    return sectionHeaderUIView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return [self.cards count];
    NSString *sectionTitle = [sectionNames objectAtIndex:section];
    NSMutableArray *sectionAnimals = [sections objectForKey:sectionTitle];
    return [sectionAnimals count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sectionNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    NSString *sectionTitle = [sectionNames objectAtIndex:indexPath.section];
    NSMutableArray *sectionCards = [sections objectForKey:sectionTitle];
    Card* currentCard = [sectionCards objectAtIndex:indexPath.row];
    UIFont *textLabelFont = [UIFont fontWithName:@"Avenir-Light" size:18.0];
    cell.textLabel.font = textLabelFont;
    cell.textLabel.text = currentCard.name;
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

@end