//
//  EmployeesTableViewController.m
//  To4ka.2
//
//  Created by Air on 28.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import "EmployeesTableViewController.h"
#import "AddEmployeeTableViewController.h"
#import "EditEmployeeTableViewController.h"

@import AddressBook;

@interface EmployeesTableViewController ()

@end

@implementation EmployeesTableViewController


@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize employeeToDelate;

-(NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)sender{
    
    if ([[segue identifier]isEqualToString:@"addEmployee"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        AddEmployeeTableViewController *addEmployeeTabelViewController = (AddEmployeeTableViewController*)navigationController.topViewController;
        
        Employee *addEmployee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:[self managedObjectContext]];
        
        addEmployeeTabelViewController.addEmployee = addEmployee;
    }
    
    if ([[segue identifier]isEqualToString:@"editEmployee"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        EditEmployeeTableViewController *editEmployeeViewController = (EditEmployeeTableViewController*)navigationController.topViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Employee *editEmployee = (Employee*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        editEmployeeViewController.editEmployee = editEmployee;
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
    
    self.searchPredicate = searchText.length == 0? nil : [NSPredicate predicateWithFormat:@"self.employeeShop BEGINSWITH[cd]%@ or self.employeeFirstName BEGINSWITH[cd]%@ or self.employeeLastName BEGINSWITH[cd]%@",searchText,searchText,searchText];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchPredicate == nil ? [[self.fetchedResultsController sections]count] : 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.searchPredicate == nil) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo name];
    }
    else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchPredicate == nil) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections]
        [section];
        return [sectionInfo numberOfObjects];
    }
    else {
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
    
    Employee *employee = nil;
    if (self.searchPredicate == nil) {
        employee = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    else {
        employee = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:self.
                       searchPredicate][indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = employee.employeeShop;
    cell.detailTextLabel.text = employee.employeeFirstName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Employee *EmployeeToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:EmployeeToDelete];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        
        CFStringRef nameRef = (__bridge CFStringRef)
        
        [NSString stringWithFormat:@"%@, %@, %@",
         [EmployeeToDelete valueForKey:@"employeeFirstName"],
         [EmployeeToDelete valueForKey:@"employeeShop"],
         [EmployeeToDelete valueForKey:@"employeeLastName"]];
        
        CFArrayRef  AllRecords_ = ABAddressBookCopyPeopleWithName(addressBook, nameRef);
        
        if (AllRecords_ != NULL){
            int count = CFArrayGetCount(AllRecords_);
            for (int i = 0; i < count; ++i)
            {
                ABRecordRef contact = CFArrayGetValueAtIndex(AllRecords_, i);
                ABAddressBookRemoveRecord(addressBook, contact, nil);
            }
        }
        ABAddressBookSave(addressBook, nil);
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"employeeFirstName"
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