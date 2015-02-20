//
//  DistributorsTableViewController.h
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Distributor.h"



@interface DistributorsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchResultsUpdating>

@property (nonatomic,strong) Distributor *distributor;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) NSPredicate *searchPredicate;



@end

