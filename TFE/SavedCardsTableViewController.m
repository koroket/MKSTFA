//
//  SavedCardsTableViewController.m
//  TFE
//
//  Created by sloot on 11/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SavedCardsTableViewController.h"
#import "AppDelegate.h"
#import "Card.h"
#import "NetworkCommunication.h"
@interface SavedCardsTableViewController ()

@end

@implementation SavedCardsTableViewController
{
    NSMutableDictionary* sections;
    NSMutableArray* sectionNames;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    sectionNames = [NSMutableArray array];
    sections = [NSMutableDictionary dictionary];
    if (self) {
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray* temp = [context executeFetchRequest:fetchRequest error:&error];
        self.cards = [temp mutableCopy];
        for(int i = 0; i<self.cards.count; i++)
        {
            if(sections[((Card*)self.cards[i]).city]==nil)
            {
                sections[((Card*)self.cards[i]).city] = [NSMutableArray arrayWithObjects:self.cards[i], nil];
                [sectionNames addObject:((Card*)self.cards[i]).city];
            }
            else
            {
                [(NSMutableArray*)sections[((Card*)self.cards[i]).city] addObject:self.cards[i]];
            }
        }
        
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        } else {
            NSLog(@"%@", self.cards);
        }
        
    }
    
    return self;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [sectionNames objectAtIndex:indexPath.section];
    NSMutableArray *sectionCards = [sections objectForKey:sectionTitle];
    [NetworkCommunication sharedManager].currentCard = [sectionCards objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionNames objectAtIndex:section];
}
#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    //return [self.cards count];
    NSString *sectionTitle = [sectionNames objectAtIndex:section];
    NSMutableArray *sectionAnimals = [sections objectForKey:sectionTitle];
    return [sectionAnimals count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [sectionNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    
    NSString *sectionTitle = [sectionNames objectAtIndex:indexPath.section];
    NSMutableArray *sectionCards = [sections objectForKey:sectionTitle];
    Card* currentCard = [sectionCards objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentCard.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    
    
    [context deleteObject:self.cards[indexPath.row]];
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else
    {
        NSString *sectionTitle = [sectionNames objectAtIndex:indexPath.section];
        [(NSMutableArray*)[sections objectForKey:sectionTitle] removeObject:((NSMutableArray*)[sections objectForKey:sectionTitle])[indexPath.row]];
        [self.cards removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
