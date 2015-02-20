//
//  StoreTableViewController.h
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Store.h"

@interface StoreTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UISearchResultsUpdating>

@property (nonatomic,strong) Store *storeToDelate;;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) NSPredicate *searchPredicate;


@end

// when editing the storeName is necessary to forbid the same storeName from CoreData

// -[UIWindow endDisablingInterfaceAutorotationAnimated:] called on <UITextEffectsWindow: 0x79644600; frame = (0 0; 320 480); opaque = NO; autoresize = W+H; gestureRecognizers = <NSArray: 0x79644e60>; layer = <UIWindowLayer: 0x79644870>> without matching -beginDisablingInterfaceAutorotation. Ignoring.

//2015-02-13 12:09:04.936 To4ka.2[2519:69885] Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates