//
//  AddStoreTableViewController.h
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"
#import "CancelSave.h"


@interface AddStoreTableViewController : CancelSave


@property (strong,nonatomic) Store *addStore;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *storeName;
@property (weak, nonatomic) IBOutlet UITextField *storePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *storeSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *storeEmail;
@property (weak, nonatomic) IBOutlet UITextView *storeNoteView;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;

@property (weak, nonatomic) IBOutlet UIButton *addSecondStorePhoneNumberButtone;


@end
