//
//  EditStoreTableViewController.h
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"
#import "CancelSave.h"

@interface EditStoreTableViewController : CancelSave <UITextFieldDelegate>


@property (nonatomic,strong)Store *editStore;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *storeName;
@property (weak, nonatomic) IBOutlet UITextField *storePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *storeSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *storeEmail;
@property (weak, nonatomic) IBOutlet UITextView *storeNoteView;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;
@property (assign, nonatomic) bool hideSectionAddPhone;

@property (weak, nonatomic) IBOutlet UIButton *addSecondStorePhoneNumberButtone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)editSave:(UIBarButtonItem *)sender;

@end
