//
//  EmployeesTableViewController.h
//  To4ka.2
//
//  Created by Air on 28.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Employee.h"

@interface EmployeesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchResultsUpdating>

@property (nonatomic,strong) Employee *employeeToDelate;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) NSPredicate *searchPredicate;



@end
// Employee Done - DeteOfBirth saving in AddressBook one day before!!!
// no index path for table cell being reused
// xcode Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
//-[UIWindow endDisablingInterfaceAutorotationAnimated:] called on <UITextEffectsWindow: 0x799aff40; frame = (0 0; 320 480); opaque = NO; gestureRecognizers = <NSArray: 0x799b06e0>; layer = <UIWindowLayer: 0x799b01b0>> without matching -beginDisablingInterfaceAutorotation. Ignoring.