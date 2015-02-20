//
//  EditShopTableViewController.h
//  To4ka.2
//
//  Created by Air on 22.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"
#import "CancelSave.h"

@interface EditShopTableViewController : CancelSave <UITextFieldDelegate>


@property (nonatomic,strong)Shop *editShop;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *shopName;
@property (weak, nonatomic) IBOutlet UITextField *shopPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *shopSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *shopEmail;
@property (weak, nonatomic) IBOutlet UITextView *shopNoteView;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;
@property (assign, nonatomic) bool hideSectionAddPhone;

@property (weak, nonatomic) IBOutlet UIButton *addSecondShopPhoneNumberButtone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)editSave:(UIBarButtonItem *)sender;

@end
