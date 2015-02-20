//
//  CancelSaveAndDissmiss.m
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import "CancelSaveAndDissmiss.h"
#import "AppDelegate.h"

@interface CancelSaveAndDissmiss ()

@end

@implementation CancelSaveAndDissmiss

-(NSManagedObjectContext*) managedObjectContext{
    
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelAndDismiss{
    
    [self.managedObjectContext rollback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveAndDissmiss{
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Save Failed: %@", [error localizedDescription]);
        }else{
            NSLog(@"Save Succeeded!");
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
