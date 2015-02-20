//
//  CancelSaveAndDissmiss.h
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CancelSaveAndDissmiss : UIViewController

@property (nonatomic,strong)NSManagedObjectContext *managedObjectContext;

-(void) cancelAndDismiss;

-(void) saveAndDissmiss;

@end
