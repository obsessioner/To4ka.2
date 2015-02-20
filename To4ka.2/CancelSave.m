//
//  CancelSave.m
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import "CancelSave.h"
#import "AppDelegate.h"

@interface CancelSave ()

@property (nonatomic,strong)NSManagedObjectContext *managedObjectContext;

@end

@implementation CancelSave

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
            
            UIAlertView *saveFailed = [[UIAlertView alloc]initWithTitle:@"Save Failed: %@" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [saveFailed show];
            NSLog(@"Save Failed: %@", [error localizedDescription]);
        }
        else{
            UIAlertView *save = [[UIAlertView alloc]initWithTitle:@"Saved" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [save show];
            NSLog(@"Save Succeeded!");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
