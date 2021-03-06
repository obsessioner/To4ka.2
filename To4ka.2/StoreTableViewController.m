//
//  StoreTableViewController.m
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import "StoreTableViewController.h"
#import "AddStoreTableViewController.h"
#import "EditStoreTableViewController.h"

@import AddressBook;

@interface StoreTableViewController ()

@end

@implementation StoreTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize storeToDelate;

-(NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)sender{
    
    if ([[segue identifier]isEqualToString:@"addStore"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        AddStoreTableViewController *addStoreTableViewController = (AddStoreTableViewController*)navigationController.topViewController;
        
        Store *addStore = [NSEntityDescription insertNewObjectForEntityForName:@"Store" inManagedObjectContext:[self managedObjectContext]];
        
        addStoreTableViewController.addStore = addStore;
    }
    
    if ([[segue identifier]isEqualToString:@"editStore"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        EditStoreTableViewController *editStoreTableViewController = (EditStoreTableViewController*)navigationController.topViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Store *editStore = (Store*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        editStoreTableViewController.editStore = editStore;
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error = nil;
    if (![[self fetchedResultsController]performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
    //  create the search controller with this controller sdisplaying the search results
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView =self.searchController.searchBar;
    self.tableView.delegate =self;
    self.definesPresentationContext = YES;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Search


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    NSString *searchText = self.searchController.searchBar.text;
    
    self.searchPredicate = searchText.length == 0? nil : [NSPredicate predicateWithFormat:@"self.storeName BEGINSWITH[cd]%@ or self.storeNote BEGINSWITH[cd]%@",searchText, searchText];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchPredicate == nil ? [[self.fetchedResultsController sections]count] : 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.searchPredicate == nil) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo name];
    }else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchPredicate == nil) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections]
        [section];
        return [sectionInfo numberOfObjects];
    } else {
        return [[self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:self.
                 searchPredicate] count];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.searchPredicate == nil;
}

#pragma mark -
#pragma mark - Table view data source


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Store *store = nil;
    if (self.searchPredicate == nil) {
        store = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        store = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:self.
                   searchPredicate][indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = store.storeName;
    cell.detailTextLabel.text = store.storeNote;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Store *StoreToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:StoreToDelete];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        
        CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        CFIndex numGroups = CFArrayGetCount(groups);
        for(CFIndex idx=0; idx<numGroups; ++idx) {
            
            ABRecordRef groupItem = CFArrayGetValueAtIndex(groups, idx);
            
            NSString *name = (__bridge NSString *)(ABRecordCopyValue(groupItem, kABGroupNameProperty));
            if ([name isEqualToString:@"To4ka"])
                
            {
                CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupItem);
                if(members) {
                    NSUInteger count = CFArrayGetCount(members);
                    for(NSUInteger idx=0; idx<count; ++idx) {
                        
                        ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                        NSString *storeName = (__bridge NSString *)ABRecordCopyValue(person,
                                                                                    kABPersonOrganizationProperty);
                        NSString *lookingStoreName = [NSString stringWithFormat:@"%@",
                                                     [StoreToDelete valueForKey:@"storeName"]];
                        
                        if ([storeName isEqualToString:lookingStoreName]) {
                            ABAddressBookRemoveRecord(addressBook, person,nil);
                            NSLog(@"Delated");
                        }
                    }
                    CFRelease(members);
                }
            }
        }
        ABAddressBookSave(addressBook, nil);
        CFRelease(groups);
        CFRelease(addressBook);
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error! %@",error);
            
        }
    }
}

#pragma mark -
#pragma mark - Fetched Results Controller Section


-(NSFetchedResultsController*)fetchedResultsController{
    if (_fetchedResultsController !=nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"storeName"
                                                                   ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil  cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

#pragma mark -
#pragma mark - Fetched Results Controller Deligate


-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end